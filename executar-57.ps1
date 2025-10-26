Write-Host "========================================" -ForegroundColor Cyan
Write-Host "APLICANDO TODAS AS CORREÇÕES NO BANCO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

sqlcmd -S "localhost\ALYASQLEXPRESS" -d "AI_Builder_Hackthon" -U "AI_Hackthon" -P "41@H4ckth0n" -i "SQL\57_aplicar_todas_correcoes.sql"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "CORREÇÕES APLICADAS COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximo passo: Reiniciar o servidor Next.js" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor White
