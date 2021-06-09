# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command"]

ENV DOTNET_SDK_VERSION=3.1.410
ENV NODEJS_VERSION=16.3.0
ENV PS_CORE_VERSION=7.1.3
ENV OCTO_TOOL_VERSION=7.4.3145
ENV OCTO_CLIENT_VERSION=11.1.2
ENV AWS_CDK_VERSION=1.108.1

# Install Choco
RUN $ProgressPreference = 'SilentlyContinue'; `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install dotnet 3+
RUN Invoke-WebRequest 'https://dot.net/v1/dotnet-install.ps1' -outFile 'dotnet-install.ps1'; `
    .\dotnet-install.ps1 -Version "${DOTNET_SDK_VERSION}"; `
    rm dotnet-install.ps1


## Install AWS PowerShell module
## https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Install-Module -name AWSPowerShell.NetCore -RequiredVersion 4.1.9.0 -Force

## Install NodeJS
RUN choco install nodejs-lts -y --version ${NODEJS_VERSION} --no-progress

## Install Powershell Core
RUN choco install powershell-core --yes --version ${PS_CORE_VERSION} --no-progress

## Install octo
RUN choco install octopustools -y --version ${OCTO_TOOL_VERSION} --no-progress

## Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion ${OCTO_CLIENT_VERSION}

## Install aws-cdk
RUN npm install -g aws-cdk@${AWS_CDK_VERSION}

## Update path for new tools
ADD .\scripts\update_path.cmd C:\update_path.cmd
RUN .\update_path.cmd;