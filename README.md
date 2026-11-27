<div align="center">

![CrewX para OneClient](docs/assets/banner.svg)

**Uma adaptação independente do CrewX para o OneClient 1.8.9.**

![Minecraft 1.8.9](https://img.shields.io/badge/Minecraft-1.8.9-62c6a2?style=flat-square)
![Windows x64](https://img.shields.io/badge/Windows-x64-70a8ff?style=flat-square)
![Português brasileiro](https://img.shields.io/badge/Documentação-PT--BR-62c6a2?style=flat-square)

[Baixar versão de teste](https://github.com/sasazw2/CrewX-Injector/releases) · [Começar](#-como-usar) · [O que mudou](#-o-que-mudou) · [Compilar](docs/COMPILAR.md) · [Resolver problemas](docs/PROBLEMAS.md)

</div>

## ✨ Sobre o projeto

Esta adaptação do [CrewX Injector](https://github.com/4everdies/CrewX-Injector) é voltada ao ambiente Ornithe/Calamus Gen2 utilizado pelo OneClient 1.8.9. O repositório reúne o código do CrewX, as correções de compatibilidade, os testes e a compilação para Windows.

É um projeto independente, sem vínculo oficial com a Polyfrost ou com os autores originais do CrewX.

## 🚀 Como usar

1. Abra [Releases](https://github.com/sasazw2/CrewX-Injector/releases) e procure a versão de teste mais recente.
2. Em **Assets**, baixe `CrewXInjector.exe`. Para compilações mais novas ainda sem versão publicada, consulte a aba **Actions**.
3. Feche completamente o OneClient e abra novamente, para remover uma injeção anterior da memória.
4. Entre em um mundo e execute o `CrewXInjector.exe` baixado.
5. Volte ao jogo e pressione **Insert**. Configurações antigas podem conservar uma tecla personalizada.

O executável é o injector do CrewX. O launcher e o jogo são instalados separadamente. Se o menu não abrir, consulte o [guia de diagnóstico](docs/PROBLEMAS.md).

## 🔧 O que mudou

| Área | Correção |
| --- | --- |
| Mappings | Recuperação de membros registrados apenas em interfaces ou superclasses. |
| Herança | Uso da hierarquia do jogo durante o remapeamento do payload. |
| Inicialização | Os mappings empacotados acompanham a versão compilada, sem substituição automática pelos do upstream. |
| Eventos | Ordem dos eventos ajustada ao comportamento definido pelos mixins. |
| Interface | Logs da tecla recebida, do pedido de abertura e da tela selecionada. |
| Diagnóstico | Falhas de handlers e ticks são registradas no log da injeção. |

## 🧪 Estado da validação

A compilação de referência desta adaptação passou por **86 testes Java** e pela verificação estática de **4.122 referências ao Minecraft**, sem referências não resolvidas. Também houve uma comparação com uma classe `Minecraft` extraída do OneClient utilizado nos testes.

Esses resultados verificam código e referências. A abertura do menu, a renderização e o comportamento dos módulos ainda precisam ser confirmados dentro do OneClient no Windows. Não há garantia de compatibilidade com todas as versões, todos os mods ou todos os servidores.

## 🛠️ Compilar e contribuir

Consulte [como compilar](docs/COMPILAR.md). A compilação automática verifica os mappings, executa os testes, compila o executável x64 e examina o payload antes de disponibilizar o arquivo.

Ao relatar um problema, informe as versões do OneClient e do Java, a compilação utilizada e o trecho relevante dos logs. Remova tokens de acesso e dados pessoais antes de publicar.

## 🤝 Créditos e licença

- **CrewX original:** [4everdies/CrewX](https://github.com/4everdies/CrewX).
- **Base do injector:** [4everdies/CrewX-Injector](https://github.com/4everdies/CrewX-Injector), revisão de referência `ffc30cc7ed9c7c881c397397bfbc2983bd49d3d4`.
- **Adaptação para OneClient:** correções e documentação mantidas neste fork.

A licença original **CC BY-NC 4.0** está preservada em [LICENSE](LICENSE). Dependências de terceiros mantêm suas próprias licenças. A documentação anterior e as notas de procedência do MCEF estão no [README original](docs/README-original.md) e em [BUILD-RECrew.md](BUILD-RECrew.md).
