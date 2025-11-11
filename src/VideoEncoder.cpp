#include "VideoEncoder.h"
#include <QDebug>

VideoEncoder::VideoEncoder()
    : m_formatContext(nullptr)
    , m_codecContext(nullptr)
    , m_swsContext(nullptr)
    , m_videoStream(nullptr)
    , m_frame(nullptr)
    , m_packet(nullptr)
    , m_width(0)
    , m_height(0)
    , m_frameRate(0.0)
    , m_bitRate(0)
    , m_frameCount(0)
    , m_useHardwareAccel(true)
{
}

VideoEncoder::~VideoEncoder()
{
    close();
}

bool VideoEncoder::open(const QString &outputPath, int width, int height, double frameRate, int64_t bitRate)
{
    m_outputPath = outputPath;
    m_width = width;
    m_height = height;
    m_frameRate = frameRate;
    m_bitRate = bitRate;
    m_frameCount = 0;
    
    return initEncoder();
}

bool VideoEncoder::initEncoder()
{
    // 分配输出上下文
    avformat_alloc_output_context2(&m_formatContext, nullptr, nullptr, m_outputPath.toUtf8().constData());
    if (!m_formatContext) {
        return false;
    }
    
    // 查找编码器 (优先硬件加速)
    const AVCodec *codec = nullptr;
    
    if (m_useHardwareAccel) {
        // 尝试NVIDIA硬件加速
        codec = avcodec_find_encoder_by_name("h264_nvenc");
        if (!codec) {
            // 尝试Intel硬件加速
            codec = avcodec_find_encoder_by_name("h264_qsv");
        }
        if (!codec) {
            // 尝试AMD硬件加速
            codec = avcodec_find_encoder_by_name("h264_amf");
        }
    }
    
    // 如果硬件加速不可用,使用软件编码器
    if (!codec) {
        codec = avcodec_find_encoder(AV_CODEC_ID_H264);
    }
    
    if (!codec) {
        return false;
    }
    
    // 创建视频流
    m_videoStream = avformat_new_stream(m_formatContext, nullptr);
    if (!m_videoStream) {
        return false;
    }
    
    // 创建编码器上下文
    m_codecContext = avcodec_alloc_context3(codec);
    if (!m_codecContext) {
        return false;
    }
    
    // 设置编码参数
    m_codecContext->codec_id = codec->id;
    m_codecContext->codec_type = AVMEDIA_TYPE_VIDEO;
    m_codecContext->width = m_width;
    m_codecContext->height = m_height;
    m_codecContext->time_base = AVRational{1, (int)(m_frameRate * 1000)};
    m_codecContext->framerate = AVRational{(int)m_frameRate, 1};
    m_codecContext->bit_rate = m_bitRate;
    m_codecContext->gop_size = 12;
    m_codecContext->max_b_frames = 2;
    m_codecContext->pix_fmt = AV_PIX_FMT_YUV420P;
    
    // 设置预设
    if (codec->id == AV_CODEC_ID_H264) {
        av_opt_set(m_codecContext->priv_data, "preset", "medium", 0);
        av_opt_set(m_codecContext->priv_data, "tune", "zerolatency", 0);
    }
    
    // 某些格式需要全局头
    if (m_formatContext->oformat->flags & AVFMT_GLOBALHEADER) {
        m_codecContext->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
    }
    
    // 打开编码器
    if (avcodec_open2(m_codecContext, codec, nullptr) < 0) {
        return false;
    }
    
    // 复制编码器参数到流
    if (avcodec_parameters_from_context(m_videoStream->codecpar, m_codecContext) < 0) {
        return false;
    }
    
    m_videoStream->time_base = m_codecContext->time_base;
    
    // 打开输出文件
    if (!(m_formatContext->oformat->flags & AVFMT_NOFILE)) {
        if (avio_open(&m_formatContext->pb, m_outputPath.toUtf8().constData(), AVIO_FLAG_WRITE) < 0) {
            return false;
        }
    }
    
    // 写入文件头
    if (avformat_write_header(m_formatContext, nullptr) < 0) {
        return false;
    }
    
    // 初始化像素格式转换
    m_swsContext = sws_getContext(
        m_width, m_height, AV_PIX_FMT_RGB24,
        m_width, m_height, AV_PIX_FMT_YUV420P,
        SWS_BILINEAR, nullptr, nullptr, nullptr
    );
    
    if (!m_swsContext) {
        return false;
    }
    
    // 分配帧
    m_frame = av_frame_alloc();
    m_frame->format = m_codecContext->pix_fmt;
    m_frame->width = m_width;
    m_frame->height = m_height;
    
    if (av_frame_get_buffer(m_frame, 0) < 0) {
        return false;
    }
    
    m_packet = av_packet_alloc();
    
    return true;
}

void VideoEncoder::close()
{
    cleanup();
}

bool VideoEncoder::encodeFrame(const QImage &image)
{
    if (!m_codecContext || !m_frame) {
        return false;
    }
    
    // 确保帧可写
    if (av_frame_make_writable(m_frame) < 0) {
        return false;
    }
    
    // 转换QImage为RGB数据
    QImage rgbImage = image.convertToFormat(QImage::Format_RGB888);
    
    // 准备源数据
    const uint8_t *srcData[1] = { rgbImage.bits() };
    int srcLinesize[1] = { (int)rgbImage.bytesPerLine() };
    
    // 转换为YUV420P
    sws_scale(m_swsContext, srcData, srcLinesize, 0, m_height, m_frame->data, m_frame->linesize);
    
    // 设置PTS
    m_frame->pts = m_frameCount++;
    
    // 发送帧到编码器
    if (avcodec_send_frame(m_codecContext, m_frame) < 0) {
        return false;
    }
    
    // 接收编码后的数据包
    while (avcodec_receive_packet(m_codecContext, m_packet) == 0) {
        // 重新缩放时间戳
        av_packet_rescale_ts(m_packet, m_codecContext->time_base, m_videoStream->time_base);
        m_packet->stream_index = m_videoStream->index;
        
        // 写入文件
        if (av_interleaved_write_frame(m_formatContext, m_packet) < 0) {
            av_packet_unref(m_packet);
            return false;
        }
        
        av_packet_unref(m_packet);
    }
    
    return true;
}

bool VideoEncoder::finalize()
{
    if (!m_codecContext) {
        return false;
    }
    
    // 刷新编码器
    avcodec_send_frame(m_codecContext, nullptr);
    
    while (avcodec_receive_packet(m_codecContext, m_packet) == 0) {
        av_packet_rescale_ts(m_packet, m_codecContext->time_base, m_videoStream->time_base);
        m_packet->stream_index = m_videoStream->index;
        av_interleaved_write_frame(m_formatContext, m_packet);
        av_packet_unref(m_packet);
    }
    
    // 写入文件尾
    av_write_trailer(m_formatContext);
    
    return true;
}

void VideoEncoder::setHardwareAcceleration(bool enable)
{
    m_useHardwareAccel = enable;
}

void VideoEncoder::cleanup()
{
    if (m_packet) {
        av_packet_free(&m_packet);
    }
    
    if (m_frame) {
        av_frame_free(&m_frame);
    }
    
    if (m_swsContext) {
        sws_freeContext(m_swsContext);
        m_swsContext = nullptr;
    }
    
    if (m_codecContext) {
        avcodec_free_context(&m_codecContext);
    }
    
    if (m_formatContext) {
        if (!(m_formatContext->oformat->flags & AVFMT_NOFILE)) {
            avio_closep(&m_formatContext->pb);
        }
        avformat_free_context(m_formatContext);
        m_formatContext = nullptr;
    }
}
