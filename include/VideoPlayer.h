#ifndef VIDEOPLAYER_H
#define VIDEOPLAYER_H

#include <QObject>
#include <QImage>
#include <QThread>
#include <QMutex>
#include <QWaitCondition>
#include <atomic>
#include <memory>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
}

/**
 * @brief 视频播放器类
 * 
 * 在后台线程中解码视频，并通过信号发送帧到UI线程
 */
class VideoPlayer : public QObject
{
    Q_OBJECT

public:
    explicit VideoPlayer(QObject *parent = nullptr);
    ~VideoPlayer();

    // 播放控制
    bool openFile(const QString &filePath);
    void play();
    void pause();
    void stop();
    void seek(qint64 milliseconds);
    
    // 获取视频信息
    qint64 duration() const { return m_duration; }
    qint64 position() const { return m_position; }
    bool isPlaying() const { return m_isPlaying; }
    
    // 获取视频详细信息
    QString getVideoInfo() const;
    QImage getCurrentFrame();

signals:
    void frameReady(const QImage &frame);       // 新帧就绪
    void positionChanged(qint64 position);      // 播放位置改变
    void durationChanged(qint64 duration);      // 总时长改变
    void videoInfoReady(const QString &info);   // 视频信息就绪
    void error(const QString &errorMsg);        // 错误信息

private:
    void decodeLoop();              // 解码循环 (在工作线程中运行)
    bool initDecoder();             // 初始化解码器
    void cleanup();                 // 清理资源
    QImage frameToQImage(AVFrame *frame);  // 将AVFrame转换为QImage

private:
    // FFmpeg 组件
    AVFormatContext *m_formatContext;
    AVCodecContext *m_codecContext;
    SwsContext *m_swsContext;
    int m_videoStreamIndex;
    
    // 视频信息
    qint64 m_duration;              // 总时长 (毫秒)
    qint64 m_position;              // 当前位置 (毫秒)
    int m_width;                    // 视频宽度
    int m_height;                   // 视频高度
    double m_frameRate;             // 帧率
    int64_t m_bitRate;              // 码率
    int64_t m_totalFrames;          // 总帧数
    
    // 线程控制
    std::unique_ptr<QThread> m_workerThread;
    QMutex m_mutex;
    QWaitCondition m_condition;
    std::atomic<bool> m_isPlaying;
    std::atomic<bool> m_shouldStop;
    std::atomic<bool> m_seekRequested;
    std::atomic<qint64> m_seekTarget;
    
    // 当前帧
    QImage m_currentFrame;
    QString m_filePath;
};

#endif // VIDEOPLAYER_H
