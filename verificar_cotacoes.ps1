# Script PowerShell para verificar instalação do sistema de cotações
# Data: 26/10/2025

$server = ".\ALYASQLEXPRESS"
$database = "AI_Builder_Hackthon"
$username = "AI_Hackthon"
$password = "41@H4ckth0n"
$inputFile = "SQL\42_verificar_instalacao_cotacoes.sql"
$outputFile = "verificacao_cotacoes_resultado.txt"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFICANDO SISTEMA DE COTAÇÕES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Executar script SQL
Write-Host "Executando verificação..." -ForegroundColor Yellow

try {
    & sqlcmd -S $server -d $database -U $username -P $password -i $inputFile -o $outputFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Verificação executada com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Resultado salvo em: $outputFile" -ForegroundColor Green
        Write-Host ""
        
        # Exibir resultado
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "RESULTADO DA VERIFICAÇÃO" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Get-Content $outputFile
    } else {
        Write-Host "✗ Erro ao executar verificação!" -ForegroundColor Red
        Write-Host "Código de saída: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Erro: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
