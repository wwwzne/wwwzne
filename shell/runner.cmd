@echo off
set FileName=%~n2
set FileExt=%~x2
set File=%1\%2
set Build=D:\Project\Build
if /I "%FileExt%"==".php" (
    :: php执行代码
    php %File%
) else if /I "%FileExt%"==".py" (
    :: python执行代码
    python %File%
) else if /I "%FileExt%"==".js" (
    :: nodejs执行代码
    node %File%
) else if /I "%FileExt%"==".go" (
    :: go执行代码
    go build -o %Build%\%FileName%.exe %File% & %Build%\%FileName%.exe
) else if /I "%FileExt%"==".rt" (
    :: rust执行代码
    rustc -o %Build%\%FileName%.exe %File% & %Build%\%FileName%.exe
) else if /I "%FileExt%"==".cmd" (
    :: cmd执行代码
    %File%
) else if /I "%FileExt%"==".bat" (
    :: bat执行代码
    %File%
) else if /I "%FileExt%"==".ps1" (
    :: powershell执行代码
    %File%
) else if /I "%FileExt%"==".dart" (
    :: dart执行代码
    dart --disable-analytics run %File%
) else if /I "%FileExt%"==".m" (
    :: matlab(octave)执行代码
    octave-launch --no-gui %File%
) else if /I "%FileExt%"==".c" (
    :: c执行代码
    g++ -fdiagnostics-color=always -Wall -g -O3 -std=c++20 %File% -o %Build%\%FileName%.exe & %Build%\%FileName%.exe
) else if /I "%FileExt%"==".cpp" (
    :: c++执行代码
    g++ -fdiagnostics-color=always -Wall -g -O3 -std=c++20 %File% -o %Build%\%FileName%.exe & %Build%\%FileName%.exe
) else if /I "%FileExt%"==".wl" (
    :: wolfram执行代码
    wolfram -script %File%
)