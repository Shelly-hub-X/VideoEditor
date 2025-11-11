#include <QApplication>
#include "MainWindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // 设置应用程序信息
    QApplication::setApplicationName("视频剪辑助手");
    QApplication::setApplicationVersion("1.0.0");
    QApplication::setOrganizationName("VideoEditor");
    
    // 创建并显示主窗口
    MainWindow mainWindow;
    mainWindow.show();
    
    return app.exec();
}
