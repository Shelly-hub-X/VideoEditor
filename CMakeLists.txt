cmake_minimum_required(VERSION 3.20)
project(VideoEditor VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Multimedia MultimediaWidgets)

# 查找FFmpeg (通过vcpkg安装)
find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG REQUIRED IMPORTED_TARGET
    libavcodec
    libavformat
    libavutil
    libswscale
    libswresample
)

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/include
)

# 源文件
set(SOURCES
    src/main.cpp
    src/MainWindow.cpp
    src/VideoDecoder.cpp
    src/VideoEncoder.cpp
    src/VideoProcessor.cpp
    src/VideoPlayer.cpp
)

# 头文件
set(HEADERS
    include/MainWindow.h
    include/VideoDecoder.h
    include/VideoEncoder.h
    include/VideoProcessor.h
    include/VideoPlayer.h
)

# UI文件
set(UI_FILES
    ui/MainWindow.ui
)

# 创建可执行文件
add_executable(${PROJECT_NAME} WIN32
    ${SOURCES}
    ${HEADERS}
    ${UI_FILES}
)

# 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Multimedia
    Qt6::MultimediaWidgets
    PkgConfig::FFMPEG
)

# Windows特定设置
if(WIN32)
    # 设置输出目录
    set_target_properties(${PROJECT_NAME} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    )
    
    # 复制Qt DLL到输出目录
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:Qt6::Core>
        $<TARGET_FILE:Qt6::Gui>
        $<TARGET_FILE:Qt6::Widgets>
        $<TARGET_FILE_DIR:${PROJECT_NAME}>
    )
endif()

# 安装规则
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)
