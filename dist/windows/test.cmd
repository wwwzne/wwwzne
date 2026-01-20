@echo off
color 0A
cls
echo %CD%^>
for /f "delims=" %%i in ('where php 2^>nul') do set a=%%i
if defined a (
    echo [¡Ì] PHP½âÊÍÆ÷
) else (
    echo [X] PHP½âÊÍÆ÷
)
for /f "delims=" %%i in ('where node 2^>nul') do set a=%%i
if defined a (
    echo [¡Ì] nodejs½âÊÍÆ÷
) else (
    echo [X] nodejs½âÊÍÆ÷
)
for /f "delims=" %%i in ('where go 2^>nul') do set a=%%i
if defined a (
    echo [¡Ì] go½âÊÍÆ÷
) else (
    echo [X] go½âÊÍÆ÷
)
for /f "delims=" %%i in ('where python 2^>nul') do set a=%%i
if defined a (
    echo|set /p="[¡Ì] python½âÊÍÆ÷"
) else (
    echo|set /p="[X] python½âÊÍÆ÷"
)
echo>nul