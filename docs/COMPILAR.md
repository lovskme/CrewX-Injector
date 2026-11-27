# Compilar para Windows

## Requisitos

- Windows x64.
- JDK 17 para Gradle e ferramentas de empacotamento.
- JDK 8 para o projeto Java legado.
- Visual Studio com ferramentas C++ x64, Windows SDK e CMake.
- OneClient 1.8.9 instalado e executado pelo menos uma vez, ou um JAR de hierarquia fornecido explicitamente.

## Compilação local

No PowerShell, dentro da pasta do projeto:

```powershell
.\Build-Injector.ps1 -Jdk17 'C:\caminho\jdk-17' -Jdk8 'C:\caminho\jdk-8'
```

O script procura o JAR em `%APPDATA%\Polyfrost\OneClient\metadata\versions`. Para indicar outro caminho:

```powershell
.\Build-Injector.ps1 -Jdk17 'C:\caminho\jdk-17' -Jdk8 'C:\caminho\jdk-8' -OneClientGame 'C:\caminho\jogo-1.8.9.jar'
```

O resultado fica em `dist\CrewXInjector.exe`. O empacotamento para se não encontrar o JAR necessário para verificar a herança.

## Compilação automática

O fluxo `.github/workflows/windows.yml` usa o código deste próprio repositório. Ele prepara os JDKs, regenera os mappings, executa os testes e compila o executável. A verificação estática usa a hierarquia do cliente vanilla 1.8.9 obtido da Mojang, com o hash conferido.

O artefato `CrewX-OneClient-Windows-x64` só é disponibilizado quando todas as etapas passam. Ele fica na execução correspondente, na aba **Actions**. Os relatórios ficam no artefato de diagnóstico.

## Mappings em runtime

Por padrão, a aplicação usa os recursos empacotados junto do payload, mantendo a compilação e o transformador em runtime no mesmo conjunto de dados.

Para desenvolvimento, `-Dcrewx.mappings.document=C:\caminho\mappings.json` permite fornecer um documento explícito. O download remoto legado exige `-Dcrewx.mappings.remote=true`; ele não é necessário para usar esta adaptação.

Os comandos exatos de regeneração e verificação estão no fluxo de compilação. Preserve `LICENSE` e os créditos ao redistribuir alterações.
