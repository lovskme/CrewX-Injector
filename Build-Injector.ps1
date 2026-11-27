param(
    [string]$Jdk17 = $env:JAVA_HOME,
    [string]$Jdk8,
    [string]$OneClientGame
)

$ErrorActionPreference = 'Stop'
$taskRoot = $PSScriptRoot
$taskJavaProject = $taskRoot
$taskNative = Join-Path $taskRoot 'native'
$taskTools = Join-Path $taskRoot 'tools'
$taskOutput = Join-Path $taskRoot 'dist'

if (-not $Jdk17 -or -not (Test-Path -LiteralPath (Join-Path $Jdk17 'bin\javac.exe'))) {
    throw 'Informe o JDK 17: .\Build-Injector.ps1 -Jdk17 "C:\caminho\jdk-17"'
}
$env:JAVA_HOME = (Resolve-Path -LiteralPath $Jdk17).Path
$taskJava = Join-Path $env:JAVA_HOME 'bin\java.exe'
$taskJavac = Join-Path $env:JAVA_HOME 'bin\javac.exe'
if (-not $Jdk8 -or -not (Test-Path -LiteralPath (Join-Path $Jdk8 'bin\javac.exe'))) {
    throw 'Informe o JDK 8: .\Build-Injector.ps1 -Jdk17 "C:\caminho\jdk-17" -Jdk8 "C:\caminho\jdk-8"'
}
$Jdk8 = (Resolve-Path -LiteralPath $Jdk8).Path

$taskGradleProperties = Join-Path $taskJavaProject 'gradle.properties'
$taskOriginalProperties = [System.IO.File]::ReadAllBytes($taskGradleProperties)
$taskGradleJdk8 = $Jdk8.Replace('\', '/')
[System.IO.File]::AppendAllText($taskGradleProperties,
    "`r`norg.gradle.java.installations.paths=$taskGradleJdk8`r`n")
Push-Location $taskJavaProject
try {
    & (Join-Path $taskJavaProject 'gradlew.bat') assemble
    if ($LASTEXITCODE -ne 0) { throw 'Falha no build Java do CrewX.' }
} finally {
    Pop-Location
    [System.IO.File]::WriteAllBytes($taskGradleProperties, $taskOriginalProperties)
}

$taskAsmBase = Join-Path $env:USERPROFILE '.gradle\caches\modules-2\files-2.1\org.ow2.asm'
$taskAsmJars = @()
foreach ($taskModule in @('asm', 'asm-commons', 'asm-tree')) {
    $taskCandidates = @(Get-ChildItem -LiteralPath (Join-Path $taskAsmBase $taskModule) -Recurse -Filter "$taskModule-9.11.1.jar" -File -ErrorAction SilentlyContinue)
    if ($taskCandidates.Count -eq 0) { throw "Dependencia ASM 9.11.1 ausente: $taskModule" }
    $taskAsmJars += $taskCandidates[0].FullName
}
$taskAsmCp = $taskAsmJars -join ';'
$taskClasses = Join-Path $taskRoot 'build-tools'
New-Item -ItemType Directory -Path $taskClasses -Force | Out-Null
& $taskJavac -cp $taskAsmCp -d $taskClasses (Join-Path $taskTools 'AccessorRewriter.java') (Join-Path $taskTools 'RemapCrewToNotch.java') (Join-Path $taskTools 'GenerateCheatBreakerSrg.java') (Join-Path $taskTools 'GenerateOrnitheSrg.java') (Join-Path $taskTools 'PayloadCompatibilityCheck.java') (Join-Path $taskTools 'VerifyCrewCheatBreakerPayload.java')
if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar as ferramentas de empacotamento.' }

$taskLibs = Join-Path $taskJavaProject 'build\libs'
$taskGsonJar = @(Get-ChildItem -LiteralPath (Join-Path $env:USERPROFILE '.gradle\caches\modules-2\files-2.1\com.google.code.gson\gson') -Recurse -Filter 'gson-2.2.4.jar' -File -ErrorAction SilentlyContinue | Select-Object -First 1)
if ($taskGsonJar.Count -eq 0) { throw 'Dependencia Gson 2.2.4 ausente.' }
$taskBootClasses = Join-Path $taskClasses 'cmpack-boot'
if (Test-Path -LiteralPath $taskBootClasses) { Remove-Item -LiteralPath $taskBootClasses -Recurse -Force }
New-Item -ItemType Directory -Path $taskBootClasses -Force | Out-Null
$taskJdk8Javac = Join-Path $Jdk8 'bin\javac.exe'
& $taskJdk8Javac -cp "$taskAsmCp;$($taskGsonJar[0].FullName)" -d $taskBootClasses (Join-Path $taskTools 'BootRemapper.java')
if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar o remapeador CMPack.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($taskAsmJar in $taskAsmJars) {
    $taskZip = [System.IO.Compression.ZipFile]::OpenRead($taskAsmJar)
    try {
        foreach ($taskEntry in $taskZip.Entries) {
            if (-not $taskEntry.Name) { continue }
            if ($taskEntry.FullName -like 'META-INF/*' -or $taskEntry.Name -eq 'module-info.class') { continue }
            $taskDestination = Join-Path $taskBootClasses $taskEntry.FullName
            New-Item -ItemType Directory -Path (Split-Path -Parent $taskDestination) -Force | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($taskEntry, $taskDestination, $true)
        }
    } finally {
        $taskZip.Dispose()
    }
}
$taskCmpackBoot = Join-Path $taskLibs 'CrewX-cmpack-boot.jar'
if (Test-Path -LiteralPath $taskCmpackBoot) { Remove-Item -LiteralPath $taskCmpackBoot -Force }
& (Join-Path $Jdk8 'bin\jar.exe') cf $taskCmpackBoot -C $taskBootClasses .
if ($LASTEXITCODE -ne 0) { throw 'Falha ao empacotar o remapeador CMPack.' }

$taskNamedInput = Get-ChildItem -LiteralPath (Join-Path $taskJavaProject 'build\intermediates') -Filter '*non-obfuscated-with-deps.jar' -File | Select-Object -First 1
if (-not $taskNamedInput) { throw 'JAR named com dependencias nao foi gerado.' }
$taskForgeInput = Join-Path $taskLibs 'CrewX.jar'
$taskForgePayload = Join-Path $taskLibs 'CrewX-inject-forge.jar'
$taskNamedPayload = Join-Path $taskLibs 'CrewX-inject-named.jar'
$taskNotchPayload = Join-Path $taskLibs 'CrewX-inject-notch.jar'
$taskOrnithePayload = Join-Path $taskLibs 'CrewX-inject-ornithe.jar'
$taskCheatBreakerPayload = Join-Path $taskLibs 'CrewX-inject-cheatbreaker.jar'
foreach ($taskFile in @($taskForgePayload, $taskNamedPayload, $taskNotchPayload, $taskOrnithePayload, $taskCheatBreakerPayload)) {
    if (Test-Path -LiteralPath $taskFile) { Remove-Item -LiteralPath $taskFile -Force }
}
& $taskJava -cp "$taskClasses;$taskAsmCp" AccessorRewriter $taskForgeInput $taskForgePayload
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar o payload Forge.' }
& $taskJava -cp "$taskClasses;$taskAsmCp" AccessorRewriter $taskNamedInput.FullName $taskNamedPayload
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar o payload Lunar.' }

$taskMappings = Join-Path $taskJavaProject 'src\main\resources\crewx\inject'
& $taskJava -cp "$taskClasses;$taskAsmCp" RemapCrewToNotch $taskNamedPayload $taskNotchPayload `
    (Join-Path $taskMappings 'notch-joined.srg') `
    (Join-Path $taskMappings 'notch-methods.csv') `
    (Join-Path $taskMappings 'notch-fields.csv')
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar o payload Badlion.' }

$taskOrnitheMapping = Join-Path $taskClasses 'ornithe-joined.srg'
& $taskJava -cp $taskClasses GenerateOrnitheSrg `
    (Join-Path $taskMappings 'notch-joined.srg') `
    (Join-Path $taskMappings 'ornithe-intermediary.tiny') $taskOrnitheMapping
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar os mappings Ornithe.' }
$taskOneClientVersions = Join-Path $env:APPDATA 'Polyfrost\OneClient\metadata\versions'
if ($OneClientGame) {
    $taskOneClientGame = Get-Item -LiteralPath $OneClientGame
} else {
    $taskOneClientGame = Get-ChildItem -LiteralPath $taskOneClientVersions -Recurse -Filter '1.8.9-*.jar' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
if ($taskOneClientGame) {
    & $taskJava -cp "$taskClasses;$taskAsmCp" RemapCrewToNotch `
        $taskNamedPayload $taskOrnithePayload $taskOrnitheMapping `
        (Join-Path $taskMappings 'notch-methods.csv') `
        (Join-Path $taskMappings 'notch-fields.csv') $taskOneClientGame.FullName `
        (Join-Path $taskMappings 'ornithe-intermediary.tiny')
} else {
    throw 'OneClient game jar ausente. Informe -OneClientGame para validar a hierarquia; payload sem hierarquia nao sera distribuido.'
}
if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar o payload OneClient.' }

$taskCheatBreakerGame = Join-Path $env:APPDATA 'CheatBreaker\downloads\versions\1.8.9\1.8.9.patch'
$taskCheatBreakerHash = 'D6205D02A65F1EAE2513219A2E2237A826BCE33DD7B8B47680E9EE47D1F31EF8'
$taskCheatBreakerAvailable = (Test-Path -LiteralPath $taskCheatBreakerGame) -and
    ((Get-FileHash -LiteralPath $taskCheatBreakerGame -Algorithm SHA256).Hash -eq $taskCheatBreakerHash)
if ($taskCheatBreakerAvailable) {
    $taskCheatBreakerSrg = Join-Path $taskClasses 'cheatbreaker189-joined.srg'
    & $taskJava -cp $taskClasses GenerateCheatBreakerSrg `
        (Join-Path $taskMappings 'cheatbreaker189.tiny') $taskCheatBreakerSrg
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao converter os mappings CheatBreaker.' }
    & $taskJava -cp "$taskClasses;$taskAsmCp" RemapCrewToNotch `
        $taskNamedPayload $taskCheatBreakerPayload $taskCheatBreakerSrg `
        (Join-Path $taskMappings 'notch-methods.csv') `
        (Join-Path $taskMappings 'notch-fields.csv') $taskCheatBreakerGame
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao preparar o payload CheatBreaker.' }
    & $taskJava -cp "$taskClasses;$taskAsmCp" VerifyCrewCheatBreakerPayload `
        $taskCheatBreakerPayload $taskCheatBreakerGame `
        (Join-Path $taskClasses 'cheatbreaker-linkage-errors.txt')
    if ($LASTEXITCODE -ne 0) { throw 'Falha na verificacao de ligacoes do payload CheatBreaker.' }
} else {
    Write-Host 'CheatBreaker auditado ausente; gerando loader sem payload CheatBreaker.'
}

& $taskJava -cp "$taskClasses;$taskAsmCp" PayloadCompatibilityCheck $taskForgePayload $taskNamedPayload $taskNotchPayload $taskOrnithePayload
if ($LASTEXITCODE -ne 0) { throw 'Falha na verificacao de compatibilidade Forge/Lunar.' }

$taskBuild = Join-Path $taskRoot 'native-build'
$taskCmake = (Get-Command cmake.exe -ErrorAction SilentlyContinue).Source
if (-not $taskCmake) { $taskCmake = 'C:\Program Files\CMake\bin\cmake.exe' }
if (-not (Test-Path -LiteralPath $taskCmake)) {
    $taskCmake = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
}
if (-not (Test-Path -LiteralPath $taskCmake)) { throw 'CMake nao encontrado.' }
if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    $taskVswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $taskVswhere)) { throw 'Visual Studio C++ nao encontrado.' }
    $taskVsPath = & $taskVswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    $taskVsDevCmd = Join-Path $taskVsPath 'Common7\Tools\VsDevCmd.bat'
    if (-not (Test-Path -LiteralPath $taskVsDevCmd)) { throw 'VsDevCmd.bat nao encontrado.' }
    $taskEnvironment = & cmd.exe /c ('"' + $taskVsDevCmd + '" -arch=x64 >nul && set')
    foreach ($taskLine in $taskEnvironment) {
        if ($taskLine -match '^([^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
        }
    }
}
$taskSdkRoot = 'D:\winsdk'
if (-not (Get-Command rc.exe -ErrorAction SilentlyContinue) -and (Test-Path -LiteralPath $taskSdkRoot)) {
    $taskSdkCpp = Join-Path $taskSdkRoot 'microsoft.windows.sdk.cpp\c'
    $taskSdkX64 = Join-Path $taskSdkRoot 'microsoft.windows.sdk.cpp.x64\c'
    $taskSdkVersion = @(Get-ChildItem -LiteralPath (Join-Path $taskSdkCpp 'Include') -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1)[0]
    if ($taskSdkVersion) {
        $taskSdkTools = Join-Path $taskSdkRoot "microsoft.windows.sdk.buildtools\bin\$($taskSdkVersion.Name)\x64"
        if (Test-Path -LiteralPath (Join-Path $taskSdkTools 'rc.exe')) {
            $env:INCLUDE = "$($taskSdkVersion.FullName)\ucrt;$($taskSdkVersion.FullName)\shared;$($taskSdkVersion.FullName)\um;$env:INCLUDE"
            $env:LIB = "$taskSdkX64\ucrt\x64;$taskSdkX64\um\x64;$env:LIB"
            $env:PATH = "$taskSdkTools;$env:PATH"
            $env:WindowsSdkDir = "$taskSdkCpp\"
            $env:WindowsSDKVersion = "$($taskSdkVersion.Name)\"
            Write-Host "Windows SDK alternativo: $($taskSdkVersion.Name)"
        }
    }
}
$taskCmakeArgs = @('-S', $taskNative, '-B', $taskBuild, '-G', 'NMake Makefiles',
    '-DCMAKE_BUILD_TYPE=Release', "-DCREWX_JAVA_HOME=$env:JAVA_HOME",
    "-DCREWX_PRODUCT_JAR=$taskForgePayload",
    "-DCREWX_PRODUCT_JAR_NAMED=$taskNamedPayload",
    "-DCREWX_PRODUCT_JAR_NOTCH=$taskNotchPayload",
    "-DCREWX_PRODUCT_JAR_ORNITHE=$taskOrnithePayload",
    "-DCREWX_CMPACK_BOOT=$taskCmpackBoot")
if ($taskCheatBreakerAvailable) {
    $taskCmakeArgs += "-DCREWX_PRODUCT_JAR_CHEATBREAKER=$taskCheatBreakerPayload"
}
& $taskCmake @taskCmakeArgs
if ($LASTEXITCODE -ne 0) { throw 'Falha na configuracao nativa.' }
& $taskCmake --build $taskBuild --config Release --target CrewXInjector
if ($LASTEXITCODE -ne 0) { throw 'Falha no build do executavel.' }
New-Item -ItemType Directory -Path $taskOutput -Force | Out-Null
$taskExe = Join-Path $taskBuild 'dist\CrewXInjector.exe'
Copy-Item -LiteralPath $taskExe -Destination (Join-Path $taskOutput 'CrewXInjector.exe') -Force
Write-Host "Concluido: $(Join-Path $taskOutput 'CrewXInjector.exe')"
