#include "VideoDecoder.h"
#include <QDebug>

VideoDecoder::VideoDecoder()
    : m_formatContext(nullptr)
    , m_codecContext(nullptr)
    , m_swsContext(nullptr)
    , m_frame(nullptr)
    , m_packet(nullptr)
    , m_videoStreamIndex(-1)
    , m_width(0)
    , m_height(0)
    , m_frameRate(0.0)
    , m_totalFrames(0)
{
}

VideoDecoder::~VideoDecoder()
{
    close();
}

bool VideoDecoder::open(const QString &filePath)
{
    m_filePath = filePath;
    
    // 打开视频文件
    if (avformat_open_input(&m_formatContext, filePath.toUtf8().constData(), nullptr, nullptr) < 0) {
        return false;
    }
    
    // 获取流信息
    if (avformat_find_stream_info(m_formatContext, nullptr) < 0) {
        cleanup();
        return false;
    }
    
    // 查找视频流
    m_videoStreamIndex = -1;
    for (unsigned int i = 0; i < m_formatContext->nb_streams; i++) {
        if (m_formatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            m_videoStreamIndex = i;
            break;
        }
    }
    
    if (m_videoStreamIndex == -1) {
        cleanup();
        return false;
    }
    
    return initDecoder();
}

bool VideoDecoder::initDecoder()
{
    AVCodecParameters *codecParams = m_formatContext->streams[m_videoStreamIndex]->codecpar;
    const AVCodec *codec = avcodec_find_decoder(codecParams->codec_id);
    
    if (!codec) {
        return false;
    }
    
    m_codecContext = avcodec_alloc_context3(codec);
    if (!m_codecContext) {
        return false;
    }
    
    if (avcodec_parameters_to_context(m_codecContext, codecParams) < 0) {
        return false;
    }
    
    if (avcodec_open2(m_codecContext, codec, nullptr) < 0) {
        return false;
    }
    
    // 获取视频信息
    AVStream *stream = m_formatContext->streams[m_videoStreamIndex];
    m_width = m_codecContext->width;
    m_height = m_codecContext->height;
    
    if (stream->avg_frame_rate.den != 0) {
        m_frameRate = av_q2d(stream->avg_frame_rate);
    } else {
        m_frameRate = 25.0;
    }
    
    if (stream->nb_frames > 0) {
        m_totalFrames = stream->nb_frames;
    } else {
        int64_t duration = m_formatContext->duration / AV_TIME_BASE;
        m_totalFrames = duration * m_frameRate;
    }
    
    // 初始化像素格式转换
    m_swsContext = sws_getContext(
        m_width, m_height, m_codecContext->pix_fmt,
        m_width, m_height, AV_PIX_FMT_RGB24,
        SWS_BILINEAR, nullptr, nullptr, nullptr
    );
    
    if (!m_swsContext) {
        return false;
    }
    
    m_frame = av_frame_alloc();
    m_packet = av_packet_alloc();
    
    return true;
}

void VideoDecoder::close()
{
    cleanup();
}

bool VideoDecoder::decodeNextFrame(QImage &frame)
{
    while (av_read_frame(m_formatContext, m_packet) >= 0) {
        if (m_packet->stream_index == m_videoStreamIndex) {
            if (avcodec_send_packet(m_codecContext, m_packet) == 0) {
                if (avcodec_receive_frame(m_codecContext, m_frame) == 0) {
                    frame = avFrameToQImage(m_frame);
                    av_packet_unref(m_packet);
                    return true;
                }
            }
        }
        av_packet_unref(m_packet);
    }
    
    return false;
}

QImage VideoDecoder::avFrameToQImage(AVFrame *frame)
{
    AVFrame *rgbFrame = av_frame_alloc();
    int numBytes = av_image_get_buffer_size(AV_PIX_FMT_RGB24, m_width, m_height, 1);
    uint8_t *buffer = (uint8_t *)av_malloc(numBytes);
    
    av_image_fill_arrays(rgbFrame->data, rgbFrame->linesize, buffer, AV_PIX_FMT_RGB24, m_width, m_height, 1);
    sws_scale(m_swsContext, frame->data, frame->linesize, 0, m_height, rgbFrame->data, rgbFrame->linesize);
    
    QImage image(m_width, m_height, QImage::Format_RGB888);
    for (int y = 0; y < m_height; y++) {
        memcpy(image.scanLine(y), rgbFrame->data[0] + y * rgbFrame->linesize[0], m_width * 3);
    }
    
    av_free(buffer);
    av_frame_free(&rgbFrame);
    
    return image;
}

bool VideoDecoder::reset()
{
    av_seek_frame(m_formatContext, m_videoStreamIndex, 0, AVSEEK_FLAG_BACKWARD);
    avcodec_flush_buffers(m_codecContext);
    return true;
}

void VideoDecoder::cleanup()
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
        avformat_close_input(&m_formatContext);
    }
}
