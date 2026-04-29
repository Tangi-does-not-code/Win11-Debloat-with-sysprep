
#remover os arquivos temp

Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

#destiva a telemetria
Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service "DiagTrack" -Force -ErrorAction SilentlyContinue


#Tira os apps da xbox
Get-AppxPackage *xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*xbox*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue


#Tira todos os servicos da xbox (literalmente tudo, entao se voce for ultilizar esse codigo aqui com o gamepass ou algo do tipo, nao vai dar certo)
Stop-Service "XblAuthManager" -Force -ErrorAction SilentlyContinue
Stop-Service "XblGameSave" -Force -ErrorAction SilentlyContinue
Stop-Service "XboxNetApiSvc" -Force -ErrorAction SilentlyContinue
Stop-Service "XboxGipSvc" -Force -ErrorAction SilentlyContinue

Set-Service "XblAuthManager" -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service "XblGameSave" -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service "XboxNetApiSvc" -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service "XboxGipSvc" -StartupType Disabled -ErrorAction SilentlyContinue


#exclui a cortana
Get-AppxPackage *cortana* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*cortana*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

#remobe o bingweather (o wiget de clima)
Get-AppxPackage *bingweather* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*bingweather*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

#remove o news (o wiget de noticias)
Get-AppxPackage *news* | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*news*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

#remove dicas e sugestoes
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -ErrorAction SilentlyContinue

#ativa automaticamente o modo desempenho
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue

#ativa o modo de alto desempenho do windows (vai puxar mais energia, mas vai melhorar o desempenho)
powercfg -setactive SCHEME_MIN

#Desativa os apps em segundo plano
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -ErrorAction SilentlyContinue | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "Disabled" -Value 1 -ErrorAction SilentlyContinue
}

#tira o copilot completamente
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -ErrorAction SilentlyContinue



# --- Configuração de Wallpaper para o Usuário Padrão (Default User) ---
# Isso garante que novos usuários do domínio recebam a configuração

Write-Host "Configurando cor de fundo azul para o perfil de usuário padrão..." -ForegroundColor Cyan

$DefaultUserHive = "C:\Users\Default\NTUSER.DAT"

# Verifica se o arquivo existe antes de tentar carregar
if (Test-Path $DefaultUserHive) {
    # 1. Carrega a colmeia do Registro do Usuário Padrão
    reg load "HKU\DefUser_Mount" $DefaultUserHive

    # 2. Aplica a cor azul (RGB: 0 120 215) e remove o caminho do wallpaper
    Set-ItemProperty -Path "HKU\DefUser_Mount\Control Panel\Colors" -Name "Background" -Value "0 120 215" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKU\DefUser_Mount\Control Panel\Desktop" -Name "Wallpaper" -Value "" -ErrorAction SilentlyContinue

    # 3. Força a limpeza de memória para garantir que o arquivo não fique preso
    [gc]::Collect()
    Start-Sleep -Seconds 2

    # 4. Descarrega a colmeia
    reg unload "HKU\DefUser_Mount"
    Write-Host "Perfil padrão atualizado com sucesso." -ForegroundColor Green
} else {
    Write-Warning "Arquivo NTUSER.DAT padrão não encontrado em $DefaultUserHive"
}
# -----------------------------------------------------------------------
#aplica as mudancas visuais
rundll32.exe user32.dll,UpdatePerUserSystemParameters

#reinicia o explorer
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

#checa se tem algum update no Windows e se tiver atualiza
Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
Get-WindowsUpdate -Install -AcceptAll -AutoReboot


#ai ele reinicia.
Restart-Computer -Force
