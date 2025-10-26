Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REPROCESSAR COTAÇÕES INCORRETAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ler .env.local e extrair GEMINI_API_KEY
$envFile = ".\.env.local"

if (Test-Path $envFile) {
    Write-Host "📄 Lendo arquivo .env.local..." -ForegroundColor Yellow
    
    $content = Get-Content $envFile
    $apiKey = $null
    
    foreach ($line in $content) {
        if ($line -match "^GEMINI_API_KEY=(.+)$") {
            $apiKey = $matches[1].Trim()
            break
        }
    }
    
    if ($apiKey) {
        Write-Host "✅ API Key encontrada!" -ForegroundColor Green
        Write-Host "   Preview: $($apiKey.Substring(0, [Math]::Min(10, $apiKey.Length)))..." -ForegroundColor Gray
        Write-Host ""
        
        # Definir variável de ambiente
        $env:GEMINI_API_KEY = $apiKey
        
        Write-Host "Este script vai:" -ForegroundColor Yellow
        Write-Host "  1. Buscar logs finalizados incorretamente" -ForegroundColor White
        Write-Host "  2. Gerar cotações com IA" -ForegroundColor White
        Write-Host "  3. Salvar no banco de dados" -ForegroundColor White
        Write-Host ""
        Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
        
        # Executar script Node.js
        node reprocessar-cotacoes.js
        
    } else {
        Write-Host "❌ GEMINI_API_KEY não encontrada no arquivo .env.local" -ForegroundColor Red
        Write-Host "   Verifique se o arquivo contém a linha:" -ForegroundColor Yellow
        Write-Host "   GEMINI_API_KEY=sua_chave_aqui" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "❌ Arquivo .env.local não encontrado!" -ForegroundColor Red
    Write-Host "   Caminho esperado: $((Get-Location).Path)\.env.local" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "REPROCESSAMENTO CONCLUÍDO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
