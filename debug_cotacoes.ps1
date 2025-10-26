# Script para debug de cotações
$server = "localhost"
$database = "AI_Builder_Hackthon"
$username = "sa"
$password = "41@H4ckth0n"
$scriptPath = "SQL\44_debug_cotacoes.sql"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EXECUTANDO DEBUG DE COTAÇÕES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

sqlcmd -S $server -d $database -U $username -P $password -i $scriptPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DEBUG CONCLUÍDO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
