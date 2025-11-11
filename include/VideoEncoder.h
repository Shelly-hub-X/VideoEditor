#ifndef VIDEOENCODER_H
#define VIDEOENCODER_H

#include <QString>
#include <QImage>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
#include <libavutil/opt.h>
}

/**
 * @brief 视频编码器类
 * 
 * 用于视频合成功能，将图片序列和音频编码为视频
 */
class VideoEncoder
{
public:
    VideoEncoder();
    ~VideoEncoder();

    // 初始化编码器
    bool open(const QString &outputPath, int width, int height, double frameRate, int64_t bitRate = 2000000);
    
    // 关闭编码器
    void close();
    
    // 编码一帧
    bool encodeFrame(const QImage &frame);
    
    // 结束编码
    bool finalize();
    
    // 启用硬件加速
    void setHardwareAcceleration(bool enable);

private:
    bool initEncoder();
    void cleanup();
    AVFrame* qImageToAVFrame(const QImage &image);

private:
    AVFormatContext *m_formatContext;
    AVCodecContext *m_codecContext;
    SwsContext *m_swsContext;
    AVStream *m_videoStream;
    AVFrame *m_frame;
    AVPacket *m_packet;
    
    QString m_outputPath;
    int m_width;
    int m_height;
    double m_frameRate;
    int64_t m_bitRate;
    int64_t m_frameCount;
    
    bool m_useHardwareAccel;
};

#endif // VIDEOENCODER_H
