@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

echo.
echo  +--------------------------------------------------+
echo  ^|   ODONTOLOGIA BERRO -- Gerador de playlist       ^|
echo  +--------------------------------------------------+
echo.

:: Caminhos (relativos ao local do .bat)
set "PASTA=%~dp0programacao"
set "MANIFEST=%~dp0manifest.json"
set "PLAYLISTJS=%~dp0playlist.js"

:: Verifica pasta
if not exist "%PASTA%" (
    echo  [ERRO] Pasta nao encontrada: %PASTA%
    echo  Crie a pasta "programacao" ao lado deste .bat
    echo  e coloque os videos MP4 dentro dela.
    echo.
    pause
    exit /b 1
)

echo  Pasta : %PASTA%
echo  Lendo videos...
echo.

:: Conta arquivos (so minusculo: Windows e case-insensitive, evita duplicar)
set COUNT=0
for %%E in (mp4 mov webm m4v mkv) do (
    for %%F in ("%PASTA%\*.%%E") do (
        if exist "%%F" (
            set /a COUNT+=1
            echo    [!COUNT!] %%~nxF
        )
    )
)

echo.
if %COUNT%==0 (
    echo  [AVISO] Nenhum video encontrado em: %PASTA%
    echo  Formatos aceitos: .mp4  .mov  .webm  .m4v  .mkv
    echo.
    pause
    exit /b 1
)

echo  Total: %COUNT% arquivo(s)
echo  Gerando manifest.json e playlist.js...
echo.

:: === PYTHON (gera JSON valido + playlist.js correto) ===
set PYCMD=import os,json,sys;p,mf,jf=sys.argv[1],sys.argv[2],sys.argv[3];e=('.mp4','.mov','.webm','.m4v','.mkv');f=sorted([x for x in os.listdir(p) if x.lower().endswith(e)],key=str.lower);open(mf,'w',encoding='utf-8').write(json.dumps({'_info':'gerar_manifest.bat','_total':len(f),'files':f},ensure_ascii=False,indent=2));open(jf,'w',encoding='utf-8').write('window.PLAYLIST_FILES='+json.dumps(f,ensure_ascii=False)+';');print('OK:',len(f),'videos')

where python3 >nul 2>&1
if %ERRORLEVEL%==0 (
    python3 -c "%PYCMD%" "%PASTA%" "%MANIFEST%" "%PLAYLISTJS%"
    if !ERRORLEVEL!==0 goto :sucesso
)

where python >nul 2>&1
if %ERRORLEVEL%==0 (
    python -c "%PYCMD%" "%PASTA%" "%MANIFEST%" "%PLAYLISTJS%"
    if !ERRORLEVEL!==0 goto :sucesso
)

:: === FALLBACK BATCH PURO (sem Python) ===
echo  [INFO] Python nao encontrado. Gerando via batch...

> "%MANIFEST%"   echo {
>> "%MANIFEST%"  echo   "_info": "gerar_manifest.bat",
>> "%MANIFEST%"  echo   "_total": %COUNT%,
>> "%MANIFEST%"  echo   "files": [
> "%PLAYLISTJS%"  echo window.PLAYLIST_FILES = [

set FIRST=1
for %%E in (mp4 mov webm m4v mkv) do (
    for %%F in ("%PASTA%\*.%%E") do (
        if exist "%%F" (
            set "NM=%%~nxF"
            if !FIRST!==1 (
                >> "%MANIFEST%"   echo     "!NM!"
                >> "%PLAYLISTJS%" echo   "!NM!"
                set FIRST=0
            ) else (
                >> "%MANIFEST%"   echo    ,"!NM!"
                >> "%PLAYLISTJS%" echo  ,"!NM!"
            )
        )
    )
)

>> "%MANIFEST%"   echo   ]
>> "%MANIFEST%"   echo }
>> "%PLAYLISTJS%"  echo ];

:sucesso
if not exist "%PLAYLISTJS%" (
    echo  [ERRO] Falha ao criar os arquivos.
    pause
    exit /b 1
)

echo  +--------------------------------------------------+
echo  ^|   Arquivos gerados com sucesso!                  ^|
echo  +--------------------------------------------------+
echo.
echo  manifest.json : %MANIFEST%
echo  playlist.js   : %PLAYLISTJS%
echo  Videos        : %COUNT% arquivo(s)
echo.
echo  Conteudo do playlist.js:
echo  --------------------------------------------------
type "%PLAYLISTJS%"
echo.
echo  --------------------------------------------------
echo.
echo  ESTRUTURA DO PEN DRIVE:
echo    index.html
echo    playlist.js              ^<-- funciona em file://
echo    manifest.json            ^<-- funciona com servidor HTTP
echo    odontologia-berro.png
echo    gerar_manifest.bat
echo    programacao\
echo        video1.mp4
echo        video2.mp4 ...
echo.
echo  Execute sempre que adicionar ou remover videos!
echo.
pause
