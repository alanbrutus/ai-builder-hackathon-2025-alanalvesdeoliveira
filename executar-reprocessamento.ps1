Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REPROCESSAR COTAÇÕES INCORRETAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Este script vai:" -ForegroundColor Yellow
Write-Host "  1. Buscar logs finalizados incorretamente" -ForegroundColor White
Write-Host "  2. Gerar cotações com IA" -ForegroundColor White
Write-Host "  3. Salvar no banco de dados" -ForegroundColor White
Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""

node reprocessar-cotacoes.js

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "REPROCESSAMENTO CONCLUÍDO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
