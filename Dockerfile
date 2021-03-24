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
    .\dotnet-install.ps1 -Version "3.1.401"; `
    rm dotnet-install.ps1

# Install JDK
RUN choco install openjdk14 --allow-empty-checksums --yes --no-progress --version 14.0.2; refreshenv

# # Install AWS PowerShell module
# # https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Install-Module -name AWSPowerShell.NetCore -RequiredVersion 4.1.2 -Force

# # Install NodeJS
RUN choco install nodejs-lts -y --version 14.15.0 --no-progress

# # Install Powershell Core
RUN choco install powershell-core --yes --version 7.0.3 --no-progress

# # Install octo
RUN choco install octopustools -y --version 7.4.1 --no-progress

# # Install Octopus Client
RUN Install-Package Octopus.Client -source https://www.nuget.org/api/v2 -SkipDependencies -Force -RequiredVersion 8.8.3