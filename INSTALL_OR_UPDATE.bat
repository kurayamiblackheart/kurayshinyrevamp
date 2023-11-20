@echo off

.\REQUIRED_BY_INSTALLER_UPDATER\7z.exe e -spf -aoa "REQUIRED_BY_INSTALLER_UPDATER\MinGit.7z"

set mgit=".\REQUIRED_BY_INSTALLER_UPDATER\cmd\git.exe"
%mgit% init .
%mgit% remote add origin "https://github.com/kurayamiblackheart/kurayshinyrevamp.git"
%mgit% fetch origin release
%mgit% reset --hard origin/release

@REM .\REQUIRED_BY_INSTALLER_UPDATER\7z.exe e -spf -aoa -o"Data" "Data\species.zip"

echo:
echo Installer/Updater made by Hungry Pickle
echo:
echo Thank you for installing or updating! You can close this window now.
pause