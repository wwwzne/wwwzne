@echo off
set FileName=%~n2
set FileExt=%~x2
set File=%1\%2
set Build=D:\Project\Build
if /I "%FileExt%"==".php" (
    :: php执行代码
   start cmd /c "php %File% & pause"
) else if /I "%FileExt%"==".py" (
    :: python执行代码
    start cmd /c "python %File% & pause"
) else if /I "%FileExt%"==".js" (
    :: nodejs执行代码
    start cmd /c "node %File% & pause"
) else if /I "%FileExt%"==".go" (
    :: go执行代码
    go build -o %Build%\%FileName%.exe %File%
    start cmd /c "%Build%\%FileName%.exe & pause"
) else if /I "%FileExt%"==".rt" (
    :: rust执行代码
    rustc -o %Build%\%FileName%.exe %File%
    start cmd /c "%Build%\%FileName%.exe & pause"
) else if /I "%FileExt%"==".cmd" (
    :: cmd执行代码
    start cmd /c "%File% & pause"
) else if /I "%FileExt%"==".bat" (
    :: bat执行代码
    start cmd /c "%File% & pause"
) else if /I "%FileExt%"==".ps1" (
    :: powershell执行代码
    start powershell /c "%File% & pause"
) else if /I "%FileExt%"==".dart" (
    :: dart执行代码
    start cmd /c "dart --disable-analytics run %File% & pause"
) else if /I "%FileExt%"==".m" (
    :: matlab(octave)执行代码
    start cmd /c "octave-launch --no-gui %File% & pause"
) else if /I "%FileExt%"==".c" (
    :: c执行代码
    g++ -fdiagnostics-color=always -Wall -g -O3 -std=c++20 %File% -o %Build%\%FileName%.exe
    start cmd /c "%Build%\%FileName%.exe & pause"
) else if /I "%FileExt%"==".cpp" (
    :: c++执行代码
    g++ -fdiagnostics-color=always -Wall -g -O3 -std=c++20 %File% -o %Build%\%FileName%.exe
    start cmd /c "%Build%\%FileName%.exe & pause"
) else if /I "%FileExt%"==".wl" (
    :: wolfram执行代码
    start cmd /c "wolfram -script %File%.exe & pause"
)