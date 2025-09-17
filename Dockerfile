FROM mcr.microsoft.com/windows/servercore:ltsc2022

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
#RUN choco install visualStudio2017buildtools --package-parameters "--add Microsoft.VisualStudio.Component.Windows81SDK --includeRecommended" -y 
RUN choco install visualstudio2019buildtools --package-parameters "--includeRecommended" -y
RUN choco install visualstudio2019-workload-vctools --package-parameters "--includeRecommended --includeOptional" -y
#RUN Invoke-WebRequest https://aka.ms/vs/16/release/vs_buildtools.exe -OutFile C:\\vs_buildtools.exe
#COPY vsconfig.json C:\\vsconfig.json
#RUN C:\\vs_buildtools.exe --quiet --wait --norestart --nocache --includeRecommended --config C:\\vsconfig.json

# Add Python, pipx, and local user bin dir to PATH
#RUN "%path%;C:\\Users\\ContainerAdministrator\\.local\\bin\\;C:\\Python310\\Scripts;C:\\Python310\\"
SHELL ["cmd"]
RUN setx /M PATH "%PATH%;C:\\Users\\ContainerAdministrator\\.local\\bin\\;C:\\Python310\\Scripts;C:\\Python310\\"
# Default command
CMD ["cmd.exe"]