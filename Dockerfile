FROM mcr.microsoft.com/windows/servercore:1903

LABEL maintainer "Robert Raboud"

EXPOSE 80
EXPOSE 1433

# Download Links:
ENV sql "https://go.microsoft.com/fwlink/?linkid=840945"
ENV box "https://go.microsoft.com/fwlink/?linkid=840944"

ENV sqldata "c:/sqldata"
ENV datatemp "/datatemp"
ENV datapath "MSSQL14.MSSQLSERVER"
ENV servicename "MSSQLSERVER"
ENV instancname "MSSQLSERVER"


LABEL  Name=ssrs Version=0.0.4 maintainer="Robert Raboud"

ENV exe "https://download.microsoft.com/download/E/6/4/E6477A2A-9B58-40F7-8AD6-62BB8491EA78/SQLServerReportingServices.exe"

ENV sa_password="_" \
    attach_dbs="[]" \
    sa_password_path="C:\ProgramData\Docker\secrets\sa-password" \
    ssrs_user="SSRSAdmin" \
    ssrs_password="_" \
    SSRS_edition="DEV" \
    ssrs_password_path="C:\ProgramData\Docker\secrets\ssrs-password"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /

COPY stopserver.ps1 /
COPY startserver.ps1 /
COPY backupdata.ps1 /
COPY configureSSRS2017.ps1 /

RUN Invoke-WebRequest -Uri $env:box -OutFile SQL.box ; \
        Invoke-WebRequest -Uri $env:sql -OutFile SQL.exe ; \
        Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /qs, /x:setup ; \
        .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=$env:instancname /FEATURES=SQL /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS /INSTALLSQLDATADIR=$env:sqldata ; \
        Remove-Item -Recurse -Force SQL.exe, SQL.box, setup

RUN Invoke-WebRequest -Uri $env:exe -OutFile SQLServerReportingServices.exe ; \
    Start-Process -Wait -FilePath .\SQLServerReportingServices.exe -ArgumentList "/quiet", "/norestart", "/IAcceptLicenseTerms", "/Edition=$env:SSRS_edition" -PassThru -Verbose

RUN     .\startserver -Verbose ; \
        .\configureSSRS2017 -Verbose ; \
        .\stopserver -Verbose ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver' -name LoginMode -value 2 ; \
        .\backupdata -Verbose

# make install files accessible
VOLUME [ "c:/sqldata" ]

COPY start.ps1 /
COPY newadmin.ps1 /
COPY attachdatabases.ps1 /
COPY restoredata.ps1 /
COPY updatesapassword.ps1 /

# CMD Get-WmiObject win32_service | Select Name, DisplayName, State, StartMode | Sort State, Name

CMD .\start -ssrs_user $env:ssrs_user -ssrs_password $env:ssrs_password -Verbose

