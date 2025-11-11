# Use Windows Server Core with Visual Studio Build Tools
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS builder

# Install Chocolatey
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install build tools
RUN choco install -y git cmake visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

# Install vcpkg
WORKDIR /vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git . && \
    .\bootstrap-vcpkg.bat

# Install dependencies
RUN .\vcpkg install ffmpeg:x64-windows qt6-base:x64-windows qt6-multimedia:x64-windows

# Set working directory
WORKDIR /project

# Copy project files
COPY . .

# Build project
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake && \
    cmake --build . --config Release

# Package
RUN powershell -File package.ps1

# Final stage - copy only the release folder
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022
COPY --from=builder /project/release /release
CMD ["cmd", "/c", "dir", "release"]
