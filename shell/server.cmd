@echo off
:: 默认参数是调用路径，其余参数，参数一为服务器名或文件名，参数二为端口
set FileDir=%1
set Sever=%2
set FileExt=%~x2
set Port=%3
:: 默认端口8080
if "%Port%"=="" ( set Port=8080 )
if /I "%Sever%"=="symfony" (
    :: symfony服务器
    symfony server:start --port=%Port%
) else if /I "%Sever%"=="php" (
    :: php内置服务器
    php -S localhost:%Port% -t %FileDir%
) else if /I "%Sever%"=="python" (
    :: python内置服务器
    python -m http.server --bind 127.0.0.1 --cgi --directory %FileDir% %Port%
) else if /I "%Sever%"=="serve" (
    :: serve单文件路由服务器
    serve --listen %Port% --single --cors true
) else (
    if /I "%FileExt%"==".php" (
        :: php单文件路由服务器
        php -S localhost:%Port% %FileDir%\%2
    ) else if /I "%FileExt%"==".html" (
        :: http-server单文件路由服务器
        http-server -p 8080 -o
    )
)