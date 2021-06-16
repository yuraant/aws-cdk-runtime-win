# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command"]

# Install Choco
RUN $ProgressPreference = 'SilentlyContinue'; `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dotnet 3+
RUN Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'; `
    .\dotnet-install.ps1 -Channel LTS -Runtime windowsdesktop; `
    rm dotnet-install.ps1


## Install AWS PowerShell module
## https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Install-Module -name AWSPowerShell.NetCore -RequiredVersion 4.1.9.0 -Force

## Install NodeJS
RUN choco install nodejs -y --version 16.3.0 --no-progress

# Install the AWS CLI
RUN choco install awscli -y --version 2.0.60 --no-progress

## Install Powershell Core
RUN choco install powershell-core --yes --version 7.1.3 --no-progress

## Install octo
RUN choco install octopustools -y --version 7.4.3145 --no-progress

## Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion 11.1.2

## Install aws-cdk
RUN npm install -g aws-cdk@1.108.0

## Update path for new tools
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN .\update_path.cmd;