#ifndef VIDEODECODER_H
#define VIDEODECODER_H

#include <QString>
#include <QImage>
#include <vector>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
}

/**
 * @brief 视频解码器类
 * 
 * 用于视频拆分功能，将视频解码为图片序列和音频
 */
class VideoDecoder
{
public:
    VideoDecoder();
    ~VideoDecoder();

    // 打开视频文件
    bool open(const QString &filePath);
    
    // 关闭解码器
    void close();
    
    // 解码下一帧
    bool decodeNextFrame(QImage &frame);
    
    // 获取视频信息
    int getWidth() const { return m_width; }
    int getHeight() const { return m_height; }
    double getFrameRate() const { return m_frameRate; }
    int64_t getTotalFrames() const { return m_totalFrames; }
    
    // 重置到开始位置
    bool reset();

private:
    bool initDecoder();
    void cleanup();
    QImage avFrameToQImage(AVFrame *frame);

private:
    AVFormatContext *m_formatContext;
    AVCodecContext *m_codecContext;
    SwsContext *m_swsContext;
    AVFrame *m_frame;
    AVPacket *m_packet;
    
    int m_videoStreamIndex;
    int m_width;
    int m_height;
    double m_frameRate;
    int64_t m_totalFrames;
    
    QString m_filePath;
};

#endif // VIDEODECODER_H
