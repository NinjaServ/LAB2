@echo off
cd\
cd cst250\lab2
path c:\tasm\BIN;%path%
pause
tasm /la /zi lab2
pause
tlink /v lab2
