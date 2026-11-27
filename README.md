# CrewX para OneClient

CrewX adaptado para o OneClient 1.8.9, com correções nos mappings Ornithe e documentação em português.

**[Baixar para Windows](https://github.com/lovskme/CrewX-Injector/releases/download/oneclient-v0.1.0/CrewXInjector.exe)** · [Versões publicadas](https://github.com/lovskme/CrewX-Injector/releases) · [Compilar](docs/COMPILAR.md)

Windows x64 · Minecraft 1.8.9 · OneClient

## Instalação

1. Baixe o `CrewXInjector.exe` pelo link acima.
2. Abra o OneClient, inicie a versão **1.8.9** e entre em um mundo ou servidor de Minecraft.
3. Execute o `CrewXInjector.exe`.
4. Volte ao jogo e pressione **Insert**.

Uma configuração antiga pode conservar outra tecla. O launcher e o jogo são instalados separadamente.

## Alterações desta versão

- Mappings corrigidos para métodos e campos herdados de interfaces e superclasses.
- Mappings de runtime vinculados à versão compilada.
- Ordem de eventos ajustada ao comportamento dos mixins.
- Logs da abertura do menu e de erros durante a execução.

Esta é uma **versão de teste**. A compilação de referência passou por 86 testes Java e pela verificação de 4.122 referências ao Minecraft. A interface e os módulos ainda precisam de confirmação dentro do OneClient no Windows.

## Documentação

- [Como compilar](docs/COMPILAR.md)
- [Menu não abre e outros problemas](docs/PROBLEMAS.md)
- [Notas da versão](docs/NOTAS-DA-VERSAO.md)

Para relatar uma falha, informe as versões do OneClient e do Java e inclua o trecho relevante dos logs, sem tokens ou dados pessoais.

## Créditos

Esta adaptação é independente e não tem vínculo oficial com a Polyfrost.

Código original: [4everdies/CrewX](https://github.com/4everdies/CrewX) e [4everdies/CrewX-Injector](https://github.com/4everdies/CrewX-Injector). Os downloads deste fork ficam exclusivamente em [lovskme/CrewX-Injector](https://github.com/lovskme/CrewX-Injector/releases).

A licença original CC BY-NC 4.0 está preservada em [LICENSE](LICENSE). As notas sobre as dependências estão no [README original](docs/README-original.md).
