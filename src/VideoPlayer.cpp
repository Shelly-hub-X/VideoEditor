#include "VideoPlayer.h"
#include <QDebug>
#include <QThread>

VideoPlayer::VideoPlayer(QObject *parent)
    : QObject(parent)
    , m_formatContext(nullptr)
    , m_codecContext(nullptr)
    , m_swsContext(nullptr)
    , m_videoStreamIndex(-1)
    , m_duration(0)
    , m_position(0)
    , m_width(0)
    , m_height(0)
    , m_frameRate(0.0)
    , m_bitRate(0)
    , m_totalFrames(0)
    , m_isPlaying(false)
    , m_shouldStop(false)
    , m_seekRequested(false)
    , m_seekTarget(0)
{
}

VideoPlayer::~VideoPlayer()
{
    stop();
    cleanup();
}

bool VideoPlayer::openFile(const QString &filePath)
{
    // 清理之前的资源
    cleanup();
    
    m_filePath = filePath;
    
    // 打开视频文件
    if (avformat_open_input(&m_formatContext, filePath.toUtf8().constData(), nullptr, nullptr) < 0) {
        emit error("无法打开视频文件");
        return false;
    }
    
    // 获取流信息
    if (avformat_find_stream_info(m_formatContext, nullptr) < 0) {
        emit error("无法获取视频流信息");
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
        emit error("未找到视频流");
        cleanup();
        return false;
    }
    
    // 初始化解码器
    if (!initDecoder()) {
        cleanup();
        return false;
    }
    
    // 获取视频信息
    AVStream *videoStream = m_formatContext->streams[m_videoStreamIndex];
    m_width = m_codecContext->width;
    m_height = m_codecContext->height;
    m_duration = m_formatContext->duration * 1000 / AV_TIME_BASE; // 转换为毫秒
    m_bitRate = m_formatContext->bit_rate;
    
    // 计算帧率
    if (videoStream->avg_frame_rate.den != 0) {
        m_frameRate = av_q2d(videoStream->avg_frame_rate);
    } else {
        m_frameRate = 25.0; // 默认帧率
    }
    
    // 计算总帧数
    if (videoStream->nb_frames > 0) {
        m_totalFrames = videoStream->nb_frames;
    } else {
        m_totalFrames = (m_duration / 1000.0) * m_frameRate;
    }
    
    // 发送视频信息
    emit durationChanged(m_duration);
    emit videoInfoReady(getVideoInfo());
    
    // 解码第一帧
    AVPacket *packet = av_packet_alloc();
    AVFrame *frame = av_frame_alloc();
    
    while (av_read_frame(m_formatContext, packet) >= 0) {
        if (packet->stream_index == m_videoStreamIndex) {
            if (avcodec_send_packet(m_codecContext, packet) == 0) {
                if (avcodec_receive_frame(m_codecContext, frame) == 0) {
                    QImage firstFrame = frameToQImage(frame);
                    m_currentFrame = firstFrame;
                    emit frameReady(firstFrame);
                    av_packet_unref(packet);
                    break;
                }
            }
        }
        av_packet_unref(packet);
    }
    
    av_frame_free(&frame);
    av_packet_free(&packet);
    
    // 重置到开始位置
    av_seek_frame(m_formatContext, m_videoStreamIndex, 0, AVSEEK_FLAG_BACKWARD);
    avcodec_flush_buffers(m_codecContext);
    
    return true;
}

bool VideoPlayer::initDecoder()
{
    AVCodecParameters *codecParams = m_formatContext->streams[m_videoStreamIndex]->codecpar;
    
    // 查找解码器 (优先硬件加速)
    const AVCodec *codec = nullptr;
    
    // 尝试硬件加速解码器
    if (codecParams->codec_id == AV_CODEC_ID_H264) {
        codec = avcodec_find_decoder_by_name("h264_cuvid"); // NVIDIA
        if (!codec) codec = avcodec_find_decoder_by_name("h264_qsv"); // Intel
    } else if (codecParams->codec_id == AV_CODEC_ID_HEVC) {
        codec = avcodec_find_decoder_by_name("hevc_cuvid");
        if (!codec) codec = avcodec_find_decoder_by_name("hevc_qsv");
    }
    
    // 如果硬件加速不可用,使用软件解码器
    if (!codec) {
        codec = avcodec_find_decoder(codecParams->codec_id);
    }
    
    if (!codec) {
        emit error("未找到解码器");
        return false;
    }
    
    // 创建解码器上下文
    m_codecContext = avcodec_alloc_context3(codec);
    if (!m_codecContext) {
        emit error("无法创建解码器上下文");
        return false;
    }
    
    // 复制编解码参数
    if (avcodec_parameters_to_context(m_codecContext, codecParams) < 0) {
        emit error("无法复制解码器参数");
        return false;
    }
    
    // 打开解码器
    if (avcodec_open2(m_codecContext, codec, nullptr) < 0) {
        emit error("无法打开解码器");
        return false;
    }
    
    // 初始化像素格式转换上下文
    m_swsContext = sws_getContext(
        m_codecContext->width, m_codecContext->height, m_codecContext->pix_fmt,
        m_codecContext->width, m_codecContext->height, AV_PIX_FMT_RGB24,
        SWS_BILINEAR, nullptr, nullptr, nullptr
    );
    
    if (!m_swsContext) {
        emit error("无法创建像素格式转换上下文");
        return false;
    }
    
    return true;
}

void VideoPlayer::play()
{
    if (m_isPlaying) {
        return;
    }
    
    m_isPlaying = true;
    m_shouldStop = false;
    
    // 在新线程中执行解码循环
    m_workerThread = std::make_unique<QThread>();
    QObject::connect(m_workerThread.get(), &QThread::started, this, [this]() {
        decodeLoop();
    });
    m_workerThread->start();
}

void VideoPlayer::pause()
{
    m_isPlaying = false;
}

void VideoPlayer::stop()
{
    m_shouldStop = true;
    m_isPlaying = false;
    
    if (m_workerThread && m_workerThread->isRunning()) {
        m_workerThread->quit();
        m_workerThread->wait();
    }
}

void VideoPlayer::seek(qint64 milliseconds)
{
    m_seekRequested = true;
    m_seekTarget = milliseconds;
}

void VideoPlayer::decodeLoop()
{
    AVPacket *packet = av_packet_alloc();
    AVFrame *frame = av_frame_alloc();
    
    qint64 frameDelay = 1000 / m_frameRate; // 每帧延迟(毫秒)
    
    while (!m_shouldStop) {
        // 处理跳转请求
        if (m_seekRequested) {
            qint64 timestamp = (m_seekTarget * AV_TIME_BASE) / 1000;
            av_seek_frame(m_formatContext, -1, timestamp, AVSEEK_FLAG_BACKWARD);
            avcodec_flush_buffers(m_codecContext);
            m_position = m_seekTarget;
            m_seekRequested = false;
        }
        
        // 如果暂停,等待
        if (!m_isPlaying) {
            QThread::msleep(10);
            continue;
        }
        
        // 读取数据包
        int ret = av_read_frame(m_formatContext, packet);
        if (ret < 0) {
            // 到达文件末尾
            m_isPlaying = false;
            emit positionChanged(m_duration);
            av_packet_unref(packet);
            break;
        }
        
        // 只处理视频流
        if (packet->stream_index == m_videoStreamIndex) {
            // 发送数据包到解码器
            if (avcodec_send_packet(m_codecContext, packet) == 0) {
                // 接收解码后的帧
                if (avcodec_receive_frame(m_codecContext, frame) == 0) {
                    // 转换为QImage
                    QImage image = frameToQImage(frame);
                    m_currentFrame = image;
                    emit frameReady(image);
                    
                    // 更新播放位置
                    AVStream *stream = m_formatContext->streams[m_videoStreamIndex];
                    m_position = (frame->pts * 1000 * stream->time_base.num) / stream->time_base.den;
                    emit positionChanged(m_position);
                    
                    // 控制播放速度
                    QThread::msleep(frameDelay);
                }
            }
        }
        
        av_packet_unref(packet);
    }
    
    av_frame_free(&frame);
    av_packet_free(&packet);
}

QImage VideoPlayer::frameToQImage(AVFrame *frame)
{
    // 分配RGB帧
    AVFrame *rgbFrame = av_frame_alloc();
    int numBytes = av_image_get_buffer_size(AV_PIX_FMT_RGB24, m_width, m_height, 1);
    uint8_t *buffer = (uint8_t *)av_malloc(numBytes);
    
    av_image_fill_arrays(rgbFrame->data, rgbFrame->linesize, buffer, AV_PIX_FMT_RGB24, m_width, m_height, 1);
    
    // 转换像素格式
    sws_scale(m_swsContext, frame->data, frame->linesize, 0, m_height, rgbFrame->data, rgbFrame->linesize);
    
    // 创建QImage
    QImage image(m_width, m_height, QImage::Format_RGB888);
    for (int y = 0; y < m_height; y++) {
        memcpy(image.scanLine(y), rgbFrame->data[0] + y * rgbFrame->linesize[0], m_width * 3);
    }
    
    av_free(buffer);
    av_frame_free(&rgbFrame);
    
    return image;
}

QString VideoPlayer::getVideoInfo() const
{
    QString info = "<html><body style='font-family: Microsoft YaHei;'>";
    info += "<h3>视频信息</h3>";
    info += "<table cellpadding='5'>";
    info += QString("<tr><td><b>分辨率:</b></td><td>%1 x %2</td></tr>").arg(m_width).arg(m_height);
    info += QString("<tr><td><b>帧率:</b></td><td>%1 fps</td></tr>").arg(m_frameRate, 0, 'f', 2);
    info += QString("<tr><td><b>码率:</b></td><td>%1 kbps</td></tr>").arg(m_bitRate / 1000);
    info += QString("<tr><td><b>总帧数:</b></td><td>%1</td></tr>").arg(m_totalFrames);
    info += QString("<tr><td><b>时长:</b></td><td>%1 秒</td></tr>").arg(m_duration / 1000);
    info += QString("<tr><td><b>编码格式:</b></td><td>%1</td></tr>").arg(m_codecContext->codec->name);
    info += "</table>";
    info += "</body></html>";
    return info;
}

QImage VideoPlayer::getCurrentFrame()
{
    return m_currentFrame;
}

void VideoPlayer::cleanup()
{
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
    
    m_videoStreamIndex = -1;
    m_duration = 0;
    m_position = 0;
}
