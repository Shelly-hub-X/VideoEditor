#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QPushButton>
#include <QSlider>
#include <QProgressBar>
#include <QTimer>
#include <QFileDialog>
#include <QMessageBox>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGroupBox>
#include <QTextEdit>
#include <memory>

class VideoPlayer;
class VideoProcessor;

/**
 * @brief 主窗口类
 * 
 * 负责UI布局、用户交互和界面更新
 */
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    // 按钮事件处理
    void onOpenFile();              // 打开视频文件
    void onSplitVideo();            // 拆分视频
    void onMergeVideo();            // 合成视频
    void onSetCover();              // 设置封面
    void onPlayPause();             // 播放/暂停
    
    // 进度条事件
    void onSliderPressed();         // 进度条按下
    void onSliderReleased();        // 进度条释放
    void onSliderMoved(int value);  // 进度条拖动
    
    // 播放器事件
    void onFrameReady(const QImage &frame);     // 新帧就绪
    void onPositionChanged(qint64 position);    // 播放位置改变
    void onDurationChanged(qint64 duration);    // 总时长改变
    void onVideoInfoReady(const QString &info); // 视频信息就绪
    
    // 处理器事件
    void onProcessProgress(int progress);       // 处理进度更新
    void onProcessFinished(bool success, const QString &message);  // 处理完成

private:
    void setupUI();                 // 初始化UI
    void createMenuBar();           // 创建菜单栏
    void createToolBar();           // 创建工具栏
    void createCentralWidget();     // 创建中央部件
    void createStatusBar();         // 创建状态栏
    void updateButtonStates();      // 更新按钮状态
    QString formatTime(qint64 milliseconds);  // 格式化时间显示

private:
    // UI组件
    QWidget *centralWidget;
    QLabel *videoLabel;              // 视频预览标签
    QLabel *timeLabel;               // 时间显示标签
    QTextEdit *infoTextEdit;         // 视频信息显示区
    
    QPushButton *openButton;         // 打开文件按钮
    QPushButton *splitButton;        // 拆分按钮
    QPushButton *mergeButton;        // 合成按钮
    QPushButton *playButton;         // 播放/暂停按钮
    QPushButton *coverButton;        // 设置封面按钮
    
    QSlider *seekSlider;             // 进度条
    QProgressBar *progressBar;       // 处理进度条
    QLabel *statusLabel;             // 状态栏标签
    
    // 核心组件
    std::unique_ptr<VideoPlayer> videoPlayer;         // 视频播放器
    std::unique_ptr<VideoProcessor> videoProcessor;   // 视频处理器
    
    // 状态变量
    QString currentFilePath;         // 当前文件路径
    bool isSliderPressed;            // 进度条是否被按下
    bool isPlaying;                  // 是否正在播放
    qint64 videoDuration;            // 视频总时长
    QImage currentFrame;             // 当前帧
};

#endif // MAINWINDOW_H
