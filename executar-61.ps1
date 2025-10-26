Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ATUALIZANDO PROMPT DE COTAÇÃO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

sqlcmd -S "localhost\ALYASQLEXPRESS" -d "AI_Builder_Hackthon" -U "AI_Hackthon" -P "41@H4ckth0n" -i "SQL\61_atualizar_prompt_cotacao.sql"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "PROMPT ATUALIZADO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximo passo: Reiniciar o servidor Next.js" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor White
