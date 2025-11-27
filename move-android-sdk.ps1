# Script para mover Android SDK para caminho sem espaços
# Execute como Administrador se necessário

$oldPath = "C:\Users\gilmar dutra\AppData\Local\Android\sdk"
$newPath = "C:\Android\sdk"

Write-Host "Movendo Android SDK..." -ForegroundColor Cyan
Write-Host "De: $oldPath" -ForegroundColor Yellow
Write-Host "Para: $newPath" -ForegroundColor Green

# Criar diretório destino
if (-not (Test-Path $newPath)) {
    New-Item -ItemType Directory -Path $newPath -Force | Out-Null
    Write-Host "Diretório criado: $newPath" -ForegroundColor Green
}

# Copiar conteúdo (sem flags de auditoria que requerem admin)
Write-Host "`nCopiando arquivos (pode demorar alguns minutos)..." -ForegroundColor Cyan
robocopy "$oldPath" "$newPath" /E /R:3 /W:5 /MT:8 /NP

if ($LASTEXITCODE -le 7) {
    Write-Host "`nCópia concluída com sucesso!" -ForegroundColor Green
    
    # Atualizar variáveis de ambiente
    Write-Host "`nAtualizando variáveis de ambiente..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable('ANDROID_HOME', $newPath, 'User')
    [Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $newPath, 'User')
    
    # Atualizar local.properties
    $localPropsPath = ".\android\local.properties"
    if (Test-Path $localPropsPath) {
        Write-Host "Atualizando android\local.properties..." -ForegroundColor Cyan
        $content = Get-Content $localPropsPath -Raw
        $content = $content -replace [regex]::Escape($oldPath.Replace('\','/')), $newPath.Replace('\','/')
        $content = $content -replace [regex]::Escape($oldPath.Replace('\','\\')), $newPath.Replace('\','\\')
        Set-Content -Path $localPropsPath -Value $content -NoNewline
    } else {
        Write-Host "Criando android\local.properties..." -ForegroundColor Cyan
        "sdk.dir=$($newPath.Replace('\','\\'))" | Out-File -FilePath $localPropsPath -Encoding utf8
    }
    
    Write-Host "`n✓ Configuração concluída!" -ForegroundColor Green
    Write-Host "`nPróximos passos:" -ForegroundColor Yellow
    Write-Host "1. Fechar e abrir novo terminal PowerShell" -ForegroundColor White
    Write-Host "2. Executar: flutter doctor" -ForegroundColor White
    Write-Host "3. Executar: flutter clean" -ForegroundColor White
    Write-Host "4. Executar: flutter build appbundle --release" -ForegroundColor White
    Write-Host "`nSe tudo estiver OK, você pode remover a pasta antiga:" -ForegroundColor Yellow
    Write-Host "Remove-Item '$oldPath' -Recurse -Force" -ForegroundColor Gray
    
} else {
    Write-Host "`nErro ao copiar arquivos. Código: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "Tente executar como Administrador." -ForegroundColor Yellow
}
