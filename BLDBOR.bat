@echo off
cd\
cd cst250\lab2
path c:\borlandc\BIN;%path%
pause
tasm /la /zi lab2
pause
tlink /v lab2
