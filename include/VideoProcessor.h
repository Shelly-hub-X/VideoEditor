#ifndef VIDEOPROCESSOR_H
#define VIDEOPROCESSOR_H

#include <QObject>
#include <QString>
#include <QThread>
#include <memory>

class VideoDecoder;
class VideoEncoder;

/**
 * @brief 视频处理器类
 * 
 * 在后台线程中执行视频拆分和合成任务
 */
class VideoProcessor : public QObject
{
    Q_OBJECT

public:
    explicit VideoProcessor(QObject *parent = nullptr);
    ~VideoProcessor();

    // 拆分视频为图片序列 + 音频
    void splitVideo(const QString &videoPath, const QString &outputDir);
    
    // 合成图片序列 + 音频为视频
    void mergeVideo(const QString &imageDir, const QString &audioPath, const QString &outputPath);
    
    // 保存封面
    void saveCover(const QImage &frame, const QString &outputPath);

signals:
    void progressUpdated(int percentage);               // 进度更新
    void finished(bool success, const QString &message); // 处理完成
    void error(const QString &errorMsg);                // 错误信息

private slots:
    void processSplit();    // 执行拆分任务
    void processMerge();    // 执行合成任务

private:
    bool extractAudio(const QString &videoPath, const QString &audioPath);
    bool extractFrames(const QString &videoPath, const QString &framesDir);
    bool mergeFramesAndAudio(const QString &imageDir, const QString &audioPath, const QString &outputPath);

private:
    std::unique_ptr<QThread> m_workerThread;
    
    // 任务参数
    QString m_videoPath;
    QString m_outputDir;
    QString m_imageDir;
    QString m_audioPath;
    QString m_outputPath;
};

#endif // VIDEOPROCESSOR_H
