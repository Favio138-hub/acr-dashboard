@echo off
cd /d "%~dp0"
(
echo === DIAGNOSTICO %DATE% %TIME% ===
echo Carpeta: %CD%
echo.
echo --- Python ---
where py 2^>^&1
where python 2^>^&1
if exist "%LocalAppData%\Programs\Python\Python312\python.exe" echo OK Python312 user
if exist ".venv\Scripts\python.exe" echo OK venv existe
echo.
echo --- Archivos proyecto ---
if exist "backend_python\main.py" echo OK main.py
if exist "frontend\index.html" echo OK index.html
echo.
echo --- Puerto 8000 ---
netstat -ano ^| findstr ":8000"
echo.
echo --- Fin ---
) > diagnostico_log.txt 2>&1
notepad diagnostico_log.txt
pause
