ARG windowsDllSourceImage="mcr.microsoft.com/windows/server:ltsc2022"

FROM ${windowsDllSourceImage} as dll-source

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022
# DLLs for Unity Hub and Unity Editor
COPY --from=dll-source c:/windows/system32/BluetoothApis.dll \
                       c:/windows/system32/bthprops.cpl \
                       c:/windows/system32/dxva2.dll \
                       c:/windows/system32/mf.dll \
                       c:/windows/system32/mfplat.dll \
                       c:/windows/system32/mfreadwrite.dll \
                       c:/windows/system32/opengl32.dll \
                       c:/windows/system32/glu32.dll \
                       c:/windows/system32/

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force ; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ; choco feature enable -n=allowGlobalConfirmation

# Install Python, pipx, Visual Studio Build Tools, and CMake
RUN choco install python310
RUN Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1; refreshenv
RUN python -m pip install --upgrade pip
RUN python -m pip install pipx 
RUN pipx ensurepath
RUN choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'
RUN choco install strawberryperl -y
RUN choco install git
RUN choco install dotnet --version 6.0.30
RUN cpan install Win32:Registry

## VISUAL STUDIO SECTION
# Download VS Build Tools bootstrapper
RUN choco install visualstudio2022buildtools --package-parameters "--includeRecommended" --version 117.14.14 
RUN choco install visualstudio2022-workload-manageddesktop --package-parameters "--includeRecommended" --version 1.0.2
RUN choco install visualstudio2019buildtools --package-parameters "--includeRecommended" -y
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\\vs_buildtools.exe

# Copy vsconfig.json with required components
COPY vsconfig.json C:\\vsconfig.json

# Install VS Build Tools with VC 140 toolset
RUN C:\\vs_buildtools.exe --quiet --wait --norestart --nocache --includeRecommended --config C:\\vsconfig.json
# Add Python, pipx, and local user bin dir to PATH

# Unity editor section
RUN choco install unity --version 2022.3.55

SHELL ["cmd"]
RUN setx /M PATH "%PATH%;C:\\Users\\ContainerAdministrator\\.local\\bin\\;C:\\Python310\\Scripts;C:\\Python310\\;C:\Strawberry\perl\bin;"
# Default command
ENTRYPOINT ["cmd"]