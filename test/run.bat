@echo off

pushd %~dp0

nuget install pester -vers 2.0.4 -o ..\Packages

call ..\Packages\Pester.2.0.4\tools\bin\pester.bat

popd
