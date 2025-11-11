#include "MainWindow.h"
#include "VideoPlayer.h"
#include "VideoProcessor.h"
#include <QGridLayout>
#include <QGroupBox>
#include <QMenuBar>
#include <QToolBar>
#include <QStatusBar>
#include <QAction>
#include <QIcon>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , centralWidget(nullptr)
    , videoLabel(nullptr)
    , timeLabel(nullptr)
    , infoTextEdit(nullptr)
    , openButton(nullptr)
    , splitButton(nullptr)
    , mergeButton(nullptr)
    , playButton(nullptr)
    , coverButton(nullptr)
    , seekSlider(nullptr)
    , progressBar(nullptr)
    , statusLabel(nullptr)
    , isSliderPressed(false)
    , isPlaying(false)
    , videoDuration(0)
{
    // 设置窗口属性
    setWindowTitle("视频剪辑助手 v1.0");
    resize(1200, 800);
    
    // 初始化核心组件
    videoPlayer = std::make_unique<VideoPlayer>(this);
    videoProcessor = std::make_unique<VideoProcessor>(this);
    
    // 设置UI
    setupUI();
    
    // 连接信号与槽
    // 播放器信号
    connect(videoPlayer.get(), &VideoPlayer::frameReady, this, &MainWindow::onFrameReady);
    connect(videoPlayer.get(), &VideoPlayer::positionChanged, this, &MainWindow::onPositionChanged);
    connect(videoPlayer.get(), &VideoPlayer::durationChanged, this, &MainWindow::onDurationChanged);
    connect(videoPlayer.get(), &VideoPlayer::videoInfoReady, this, &MainWindow::onVideoInfoReady);
    
    // 处理器信号
    connect(videoProcessor.get(), &VideoProcessor::progressUpdated, this, &MainWindow::onProcessProgress);
    connect(videoProcessor.get(), &VideoProcessor::finished, this, &MainWindow::onProcessFinished);
    
    // 初始化按钮状态
    updateButtonStates();
}

MainWindow::~MainWindow()
{
}

void MainWindow::setupUI()
{
    createMenuBar();
    createToolBar();
    createCentralWidget();
    createStatusBar();
}

void MainWindow::createMenuBar()
{
    QMenuBar *menuBar = new QMenuBar(this);
    setMenuBar(menuBar);
    
    // 文件菜单
    QMenu *fileMenu = menuBar->addMenu("文件(&F)");
    QAction *openAction = fileMenu->addAction("打开视频(&O)...");
    openAction->setShortcut(QKeySequence::Open);
    connect(openAction, &QAction::triggered, this, &MainWindow::onOpenFile);
    
    fileMenu->addSeparator();
    QAction *exitAction = fileMenu->addAction("退出(&X)");
    exitAction->setShortcut(QKeySequence::Quit);
    connect(exitAction, &QAction::triggered, this, &QWidget::close);
    
    // 工具菜单
    QMenu *toolsMenu = menuBar->addMenu("工具(&T)");
    QAction *splitAction = toolsMenu->addAction("拆分视频(&S)");
    connect(splitAction, &QAction::triggered, this, &MainWindow::onSplitVideo);
    
    QAction *mergeAction = toolsMenu->addAction("合成视频(&M)");
    connect(mergeAction, &QAction::triggered, this, &MainWindow::onMergeVideo);
    
    // 帮助菜单
    QMenu *helpMenu = menuBar->addMenu("帮助(&H)");
    QAction *aboutAction = helpMenu->addAction("关于(&A)");
    connect(aboutAction, &QAction::triggered, this, [this]() {
        QMessageBox::about(this, "关于视频剪辑助手",
            "<h2>视频剪辑助手 v1.0</h2>"
            "<p>一款专业的视频拆分与合成工具</p>"
            "<p>基于 Qt 6 + FFmpeg 开发</p>"
            "<p>支持硬件加速，高效处理视频</p>");
    });
}

void MainWindow::createToolBar()
{
    QToolBar *toolBar = new QToolBar(this);
    toolBar->setMovable(false);
    addToolBar(Qt::TopToolBarArea, toolBar);
    
    // 打开文件按钮
    openButton = new QPushButton("打开文件", this);
    openButton->setMinimumWidth(100);
    connect(openButton, &QPushButton::clicked, this, &MainWindow::onOpenFile);
    toolBar->addWidget(openButton);
    
    toolBar->addSeparator();
    
    // 拆分视频按钮
    splitButton = new QPushButton("拆分视频", this);
    splitButton->setMinimumWidth(100);
    connect(splitButton, &QPushButton::clicked, this, &MainWindow::onSplitVideo);
    toolBar->addWidget(splitButton);
    
    // 合成视频按钮
    mergeButton = new QPushButton("合成视频", this);
    mergeButton->setMinimumWidth(100);
    connect(mergeButton, &QPushButton::clicked, this, &MainWindow::onMergeVideo);
    toolBar->addWidget(mergeButton);
}

void MainWindow::createCentralWidget()
{
    centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    
    QHBoxLayout *mainLayout = new QHBoxLayout(centralWidget);
    
    // 左侧：视频信息区
    QGroupBox *infoGroup = new QGroupBox("视频信息", this);
    QVBoxLayout *infoLayout = new QVBoxLayout(infoGroup);
    
    infoTextEdit = new QTextEdit(this);
    infoTextEdit->setReadOnly(true);
    infoTextEdit->setMaximumWidth(300);
    infoTextEdit->setPlaceholderText("请先打开视频文件...");
    infoLayout->addWidget(infoTextEdit);
    
    mainLayout->addWidget(infoGroup);
    
    // 中间：视频预览区
    QVBoxLayout *centerLayout = new QVBoxLayout();
    
    // 视频预览标签
    QGroupBox *previewGroup = new QGroupBox("视频预览", this);
    QVBoxLayout *previewLayout = new QVBoxLayout(previewGroup);
    
    videoLabel = new QLabel(this);
    videoLabel->setMinimumSize(640, 480);
    videoLabel->setAlignment(Qt::AlignCenter);
    videoLabel->setStyleSheet("QLabel { background-color: black; }");
    videoLabel->setText("未加载视频");
    videoLabel->setScaledContents(false);
    previewLayout->addWidget(videoLabel);
    
    centerLayout->addWidget(previewGroup);
    
    // 播放控制区
    QGroupBox *controlGroup = new QGroupBox("播放控制", this);
    QVBoxLayout *controlLayout = new QVBoxLayout(controlGroup);
    
    // 按钮行
    QHBoxLayout *buttonLayout = new QHBoxLayout();
    
    playButton = new QPushButton("播放", this);
    playButton->setMinimumWidth(80);
    connect(playButton, &QPushButton::clicked, this, &MainWindow::onPlayPause);
    buttonLayout->addWidget(playButton);
    
    coverButton = new QPushButton("设为封面", this);
    coverButton->setMinimumWidth(80);
    connect(coverButton, &QPushButton::clicked, this, &MainWindow::onSetCover);
    buttonLayout->addWidget(coverButton);
    
    buttonLayout->addStretch();
    
    controlLayout->addLayout(buttonLayout);
    
    // 进度条
    QHBoxLayout *sliderLayout = new QHBoxLayout();
    
    timeLabel = new QLabel("00:00:00 / 00:00:00", this);
    timeLabel->setMinimumWidth(150);
    sliderLayout->addWidget(timeLabel);
    
    seekSlider = new QSlider(Qt::Horizontal, this);
    seekSlider->setRange(0, 1000);
    seekSlider->setValue(0);
    connect(seekSlider, &QSlider::sliderPressed, this, &MainWindow::onSliderPressed);
    connect(seekSlider, &QSlider::sliderReleased, this, &MainWindow::onSliderReleased);
    connect(seekSlider, &QSlider::sliderMoved, this, &MainWindow::onSliderMoved);
    sliderLayout->addWidget(seekSlider);
    
    controlLayout->addLayout(sliderLayout);
    
    centerLayout->addWidget(controlGroup);
    
    mainLayout->addLayout(centerLayout, 1);
}

void MainWindow::createStatusBar()
{
    QStatusBar *statusBar = new QStatusBar(this);
    setStatusBar(statusBar);
    
    statusLabel = new QLabel("就绪", this);
    statusBar->addWidget(statusLabel, 1);
    
    progressBar = new QProgressBar(this);
    progressBar->setMaximumWidth(200);
    progressBar->setVisible(false);
    statusBar->addWidget(progressBar);
}

void MainWindow::onOpenFile()
{
    QString filePath = QFileDialog::getOpenFileName(
        this,
        "打开视频文件",
        "",
        "视频文件 (*.mp4 *.avi *.mkv *.mov *.flv);;所有文件 (*.*)"
    );
    
    if (filePath.isEmpty()) {
        return;
    }
    
    // 停止当前播放
    if (isPlaying) {
        videoPlayer->pause();
        isPlaying = false;
    }
    
    // 打开新视频
    if (videoPlayer->openFile(filePath)) {
        currentFilePath = filePath;
        statusLabel->setText("视频加载成功: " + QFileInfo(filePath).fileName());
        updateButtonStates();
    } else {
        QMessageBox::critical(this, "错误", "无法打开视频文件！");
    }
}

void MainWindow::onSplitVideo()
{
    if (currentFilePath.isEmpty()) {
        QMessageBox::warning(this, "提示", "请先打开视频文件！");
        return;
    }
    
    QString outputDir = QFileDialog::getExistingDirectory(
        this,
        "选择输出目录",
        "",
        QFileDialog::ShowDirsOnly
    );
    
    if (outputDir.isEmpty()) {
        return;
    }
    
    statusLabel->setText("正在拆分视频...");
    progressBar->setVisible(true);
    progressBar->setValue(0);
    
    videoProcessor->splitVideo(currentFilePath, outputDir);
}

void MainWindow::onMergeVideo()
{
    QString imageDir = QFileDialog::getExistingDirectory(
        this,
        "选择图片序列文件夹",
        "",
        QFileDialog::ShowDirsOnly
    );
    
    if (imageDir.isEmpty()) {
        return;
    }
    
    QString audioPath = QFileDialog::getOpenFileName(
        this,
        "选择音频文件",
        "",
        "音频文件 (*.mp3 *.wav *.aac *.m4a);;所有文件 (*.*)"
    );
    
    if (audioPath.isEmpty()) {
        return;
    }
    
    QString outputPath = QFileDialog::getSaveFileName(
        this,
        "保存视频文件",
        "",
        "MP4 视频 (*.mp4)"
    );
    
    if (outputPath.isEmpty()) {
        return;
    }
    
    statusLabel->setText("正在合成视频...");
    progressBar->setVisible(true);
    progressBar->setValue(0);
    
    videoProcessor->mergeVideo(imageDir, audioPath, outputPath);
}

void MainWindow::onSetCover()
{
    if (currentFrame.isNull()) {
        QMessageBox::warning(this, "提示", "没有可用的视频帧！");
        return;
    }
    
    QString outputPath = QFileDialog::getSaveFileName(
        this,
        "保存封面图片",
        "",
        "JPEG 图片 (*.jpg);;PNG 图片 (*.png)"
    );
    
    if (outputPath.isEmpty()) {
        return;
    }
    
    videoProcessor->saveCover(currentFrame, outputPath);
    QMessageBox::information(this, "成功", "封面已保存！");
}

void MainWindow::onPlayPause()
{
    if (currentFilePath.isEmpty()) {
        QMessageBox::warning(this, "提示", "请先打开视频文件！");
        return;
    }
    
    if (isPlaying) {
        videoPlayer->pause();
        playButton->setText("播放");
        isPlaying = false;
    } else {
        videoPlayer->play();
        playButton->setText("暂停");
        isPlaying = true;
    }
}

void MainWindow::onSliderPressed()
{
    isSliderPressed = true;
}

void MainWindow::onSliderReleased()
{
    isSliderPressed = false;
    if (videoDuration > 0) {
        qint64 position = (seekSlider->value() * videoDuration) / 1000;
        videoPlayer->seek(position);
    }
}

void MainWindow::onSliderMoved(int value)
{
    if (videoDuration > 0) {
        qint64 position = (value * videoDuration) / 1000;
        timeLabel->setText(formatTime(position) + " / " + formatTime(videoDuration));
    }
}

void MainWindow::onFrameReady(const QImage &frame)
{
    currentFrame = frame;
    
    // 缩放图片以适应标签
    QPixmap pixmap = QPixmap::fromImage(frame);
    pixmap = pixmap.scaled(videoLabel->size(), Qt::KeepAspectRatio, Qt::SmoothTransformation);
    videoLabel->setPixmap(pixmap);
}

void MainWindow::onPositionChanged(qint64 position)
{
    if (!isSliderPressed && videoDuration > 0) {
        int sliderValue = (position * 1000) / videoDuration;
        seekSlider->setValue(sliderValue);
        timeLabel->setText(formatTime(position) + " / " + formatTime(videoDuration));
    }
}

void MainWindow::onDurationChanged(qint64 duration)
{
    videoDuration = duration;
    timeLabel->setText("00:00:00 / " + formatTime(duration));
}

void MainWindow::onVideoInfoReady(const QString &info)
{
    infoTextEdit->setHtml(info);
}

void MainWindow::onProcessProgress(int progress)
{
    progressBar->setValue(progress);
}

void MainWindow::onProcessFinished(bool success, const QString &message)
{
    progressBar->setVisible(false);
    statusLabel->setText("就绪");
    
    if (success) {
        QMessageBox::information(this, "成功", message);
    } else {
        QMessageBox::critical(this, "错误", message);
    }
}

void MainWindow::updateButtonStates()
{
    bool hasVideo = !currentFilePath.isEmpty();
    
    splitButton->setEnabled(hasVideo);
    playButton->setEnabled(hasVideo);
    coverButton->setEnabled(hasVideo);
    seekSlider->setEnabled(hasVideo);
}

QString MainWindow::formatTime(qint64 milliseconds)
{
    int totalSeconds = milliseconds / 1000;
    int hours = totalSeconds / 3600;
    int minutes = (totalSeconds % 3600) / 60;
    int seconds = totalSeconds % 60;
    
    return QString("%1:%2:%3")
        .arg(hours, 2, 10, QChar('0'))
        .arg(minutes, 2, 10, QChar('0'))
        .arg(seconds, 2, 10, QChar('0'));
}
