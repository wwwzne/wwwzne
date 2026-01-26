@echo off
:: php解释器
for /f "delims=" %%i in ('where php 2^>nul') do set a=%%i
if defined a (
    echo|set /p=" [Yes] PHP" & echo.
) else (
    echo|set /p=" [No] PHP" & echo.
)
:: nodejs解释器
for /f "delims=" %%i in ('where node 2^>nul') do set a=%%i
if defined a (
    echo|set /p=" [Yes] nodejs" & echo.
) else (
    echo|set /p=" [No] nodejs" & echo.
)
:: go编译器
for /f "delims=" %%i in ('where go 2^>nul') do set a=%%i
if defined a (
    echo|set /p=" [Yes] go" & echo.
) else (
    echo|set /p=" [No] go" & echo.
)
:: python解释器
for /f "delims=" %%i in ('where python 2^>nul') do set a=%%i
if defined a (
    echo|set /p=" [Yes] python" & echo.
) else (
    echo|set /p=" [No] python" & echo.
)
:: rust编译器
for /f "delims=" %%i in ('where rustc 2^>nul') do set a=%%i
if defined a (
    echo|set /p=" [Yes] rustc" & echo.
) else (
    echo|set /p=" [No] rustc" & echo.
)
:: symfony服务器
for /f "delims=" %%i in ('where symfony 2^>nul') do set a=%%i
if defined a (
    echo|set /p=" [Yes] symfony" & echo.
) else (
    echo|set /p=" [No] symfony" & echo.
)