@echo off	
chcp 65001
set cocos=C:\CocosDashboard_1.0.20\resources\.editors\Creator\3.4.0\CocosCreator.exe
rem %cocos%  --project gameclient --build "platform=windows;md5Cache=false"
cd gameclient
node build.js
pause