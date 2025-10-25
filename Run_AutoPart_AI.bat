@echo off
echo ========================================
echo AutoPart AI - Iniciando Servidor
echo ========================================
echo.

echo [1/3] Finalizando processos Node.js...
taskkill /F /IM node.exe 2>nul
if %errorlevel% equ 0 (
    echo      Processos finalizados com sucesso!
) else (
    echo      Nenhum processo Node.js em execucao.
)
echo.

echo [2/3] Limpando cache do Next.js...
if exist .next (
    rmdir /S /Q .next
    echo      Cache limpo com sucesso!
) else (
    echo      Cache ja estava limpo.
)
echo.

echo [3/3] Iniciando servidor de desenvolvimento...
echo      Acesse: http://localhost:3000/chat
echo.
echo ========================================
echo.

npm run dev