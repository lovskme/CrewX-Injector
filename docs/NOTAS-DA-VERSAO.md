# CrewX para OneClient — 0.1.0

Primeira versão de teste independente para OneClient 1.8.9, baseada no CrewX Injector.

## Alterações

- Correção dos mappings Ornithe/Calamus Gen2 para membros herdados.
- Mappings de runtime vinculados ao payload compilado.
- Correção da ordem de eventos do cliente.
- Logs da abertura do menu, de handlers e de callbacks de tick.
- Documentação e guias em português brasileiro.

## Como testar

Feche completamente o OneClient, abra novamente e entre em um mundo. Execute `CrewXInjector.exe`, volte ao jogo e pressione **Insert**. Uma configuração antiga pode conservar outra tecla.

## Validação e estado

A compilação de referência passou por 86 testes Java e pela verificação estática de 4.122 referências ao Minecraft. A publicação desta versão também depende da aprovação dos testes e da verificação do payload no próprio repositório.

A renderização, a abertura do menu e os módulos ainda precisam de confirmação dentro do OneClient no Windows. Por isso, esta publicação é marcada como versão de teste.

Os créditos e a licença original permanecem no repositório. Consulte `SHA256.txt` para conferir o hash do executável.
