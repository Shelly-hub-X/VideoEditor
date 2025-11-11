#include "VideoProcessor.h"
#include "VideoDecoder.h"
#include "VideoEncoder.h"
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QProcess>

extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
}

VideoProcessor::VideoProcessor(QObject *parent)
    : QObject(parent)
{
}

VideoProcessor::~VideoProcessor()
{
    if (m_workerThread && m_workerThread->isRunning()) {
        m_workerThread->quit();
        m_workerThread->wait();
    }
}

void VideoProcessor::splitVideo(const QString &videoPath, const QString &outputDir)
{
    m_videoPath = videoPath;
    m_outputDir = outputDir;
    
    // 在工作线程中执行
    m_workerThread = std::make_unique<QThread>();
    
    QObject::connect(m_workerThread.get(), &QThread::started, this, &VideoProcessor::processSplit);
    QObject::connect(m_workerThread.get(), &QThread::finished, m_workerThread.get(), &QThread::deleteLater);
    
    m_workerThread->start();
}

void VideoProcessor::mergeVideo(const QString &imageDir, const QString &audioPath, const QString &outputPath)
{
    m_imageDir = imageDir;
    m_audioPath = audioPath;
    m_outputPath = outputPath;
    
    // 在工作线程中执行
    m_workerThread = std::make_unique<QThread>();
    
    QObject::connect(m_workerThread.get(), &QThread::started, this, &VideoProcessor::processMerge);
    QObject::connect(m_workerThread.get(), &QThread::finished, m_workerThread.get(), &QThread::deleteLater);
    
    m_workerThread->start();
}

void VideoProcessor::saveCover(const QImage &frame, const QString &outputPath)
{
    if (frame.save(outputPath)) {
        emit finished(true, "封面保存成功！");
    } else {
        emit finished(false, "封面保存失败！");
    }
}

void VideoProcessor::processSplit()
{
    // 创建输出目录
    QDir dir(m_outputDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    // 创建frames子目录
    QString framesDir = m_outputDir + "/frames";
    QDir().mkpath(framesDir);
    
    // 提取帧
    emit progressUpdated(10);
    if (!extractFrames(m_videoPath, framesDir)) {
        emit finished(false, "提取视频帧失败！");
        return;
    }
    
    emit progressUpdated(60);
    
    // 提取音频
    QString audioPath = m_outputDir + "/audio.mp3";
    if (!extractAudio(m_videoPath, audioPath)) {
        emit finished(false, "提取音频失败！");
        return;
    }
    
    emit progressUpdated(100);
    emit finished(true, "视频拆分完成！\n图片序列: " + framesDir + "\n音频文件: " + audioPath);
}

void VideoProcessor::processMerge()
{
    emit progressUpdated(10);
    
    if (!mergeFramesAndAudio(m_imageDir, m_audioPath, m_outputPath)) {
        emit finished(false, "视频合成失败！");
        return;
    }
    
    emit progressUpdated(100);
    emit finished(true, "视频合成完成！\n输出文件: " + m_outputPath);
}

bool VideoProcessor::extractFrames(const QString &videoPath, const QString &framesDir)
{
    VideoDecoder decoder;
    
    if (!decoder.open(videoPath)) {
        return false;
    }
    
    int frameCount = 0;
    int totalFrames = decoder.getTotalFrames();
    QImage frame;
    
    while (decoder.decodeNextFrame(frame)) {
        QString framePath = QString("%1/frame_%2.jpg")
            .arg(framesDir)
            .arg(frameCount, 6, 10, QChar('0'));
        
        if (!frame.save(framePath, "JPEG", 95)) {
            return false;
        }
        
        frameCount++;
        
        // 更新进度
        if (totalFrames > 0) {
            int progress = 10 + (frameCount * 50 / totalFrames);
            emit progressUpdated(progress);
        }
    }
    
    decoder.close();
    return frameCount > 0;
}

bool VideoProcessor::extractAudio(const QString &videoPath, const QString &audioPath)
{
    AVFormatContext *inputContext = nullptr;
    AVFormatContext *outputContext = nullptr;
    
    // 打开输入文件
    if (avformat_open_input(&inputContext, videoPath.toUtf8().constData(), nullptr, nullptr) < 0) {
        return false;
    }
    
    if (avformat_find_stream_info(inputContext, nullptr) < 0) {
        avformat_close_input(&inputContext);
        return false;
    }
    
    // 查找音频流
    int audioStreamIndex = -1;
    for (unsigned int i = 0; i < inputContext->nb_streams; i++) {
        if (inputContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            audioStreamIndex = i;
            break;
        }
    }
    
    if (audioStreamIndex == -1) {
        avformat_close_input(&inputContext);
        return false;
    }
    
    // 创建输出上下文
    avformat_alloc_output_context2(&outputContext, nullptr, nullptr, audioPath.toUtf8().constData());
    if (!outputContext) {
        avformat_close_input(&inputContext);
        return false;
    }
    
    // 复制音频流
    AVStream *inStream = inputContext->streams[audioStreamIndex];
    AVStream *outStream = avformat_new_stream(outputContext, nullptr);
    
    if (!outStream) {
        avformat_free_context(outputContext);
        avformat_close_input(&inputContext);
        return false;
    }
    
    avcodec_parameters_copy(outStream->codecpar, inStream->codecpar);
    outStream->codecpar->codec_tag = 0;
    
    // 打开输出文件
    if (!(outputContext->oformat->flags & AVFMT_NOFILE)) {
        if (avio_open(&outputContext->pb, audioPath.toUtf8().constData(), AVIO_FLAG_WRITE) < 0) {
            avformat_free_context(outputContext);
            avformat_close_input(&inputContext);
            return false;
        }
    }
    
    // 写入头部
    if (avformat_write_header(outputContext, nullptr) < 0) {
        avio_closep(&outputContext->pb);
        avformat_free_context(outputContext);
        avformat_close_input(&inputContext);
        return false;
    }
    
    // 复制数据包
    AVPacket *packet = av_packet_alloc();
    while (av_read_frame(inputContext, packet) >= 0) {
        if (packet->stream_index == audioStreamIndex) {
            av_packet_rescale_ts(packet, inStream->time_base, outStream->time_base);
            packet->stream_index = 0;
            av_interleaved_write_frame(outputContext, packet);
        }
        av_packet_unref(packet);
    }
    
    av_packet_free(&packet);
    
    // 写入尾部
    av_write_trailer(outputContext);
    
    // 清理
    avio_closep(&outputContext->pb);
    avformat_free_context(outputContext);
    avformat_close_input(&inputContext);
    
    return true;
}

bool VideoProcessor::mergeFramesAndAudio(const QString &imageDir, const QString &audioPath, const QString &outputPath)
{
    // 获取图片列表
    QDir dir(imageDir);
    QStringList filters;
    filters << "*.jpg" << "*.jpeg" << "*.png";
    QFileInfoList imageFiles = dir.entryInfoList(filters, QDir::Files, QDir::Name);
    
    if (imageFiles.isEmpty()) {
        emit error("图片文件夹为空！");
        return false;
    }
    
    // 读取第一张图片获取分辨率
    QImage firstImage(imageFiles.first().absoluteFilePath());
    if (firstImage.isNull()) {
        emit error("无法读取图片！");
        return false;
    }
    
    int width = firstImage.width();
    int height = firstImage.height();
    double frameRate = 25.0; // 默认帧率
    
    // 创建编码器
    VideoEncoder encoder;
    if (!encoder.open(outputPath, width, height, frameRate, 2000000)) {
        emit error("无法创建编码器！");
        return false;
    }
    
    // 编码所有图片
    int frameCount = 0;
    int totalFrames = imageFiles.size();
    
    for (const QFileInfo &fileInfo : imageFiles) {
        QImage image(fileInfo.absoluteFilePath());
        if (image.isNull()) {
            continue;
        }
        
        // 确保图片尺寸一致
        if (image.width() != width || image.height() != height) {
            image = image.scaled(width, height, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        }
        
        if (!encoder.encodeFrame(image)) {
            emit error("编码帧失败！");
            encoder.close();
            return false;
        }
        
        frameCount++;
        int progress = 10 + (frameCount * 80 / totalFrames);
        emit progressUpdated(progress);
    }
    
    // 完成编码
    encoder.finalize();
    encoder.close();
    
    // 使用FFmpeg合并音频 (如果有音频文件)
    if (!audioPath.isEmpty() && QFile::exists(audioPath)) {
        QString tempOutput = outputPath + ".temp.mp4";
        QFile::rename(outputPath, tempOutput);
        
        QProcess ffmpeg;
        QStringList args;
        args << "-i" << tempOutput
             << "-i" << audioPath
             << "-c:v" << "copy"
             << "-c:a" << "aac"
             << "-strict" << "experimental"
             << "-shortest"
             << outputPath;
        
        ffmpeg.start("ffmpeg", args);
        ffmpeg.waitForFinished(-1);
        
        if (ffmpeg.exitCode() == 0) {
            QFile::remove(tempOutput);
        } else {
            // 如果合并失败,保留纯视频文件
            QFile::rename(tempOutput, outputPath);
        }
    }
    
    emit progressUpdated(100);
    return true;
}
