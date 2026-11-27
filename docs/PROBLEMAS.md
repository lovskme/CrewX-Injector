# Resolver problemas

## O menu não abre

1. Feche o jogo completamente antes de testar uma nova compilação.
2. Abra o OneClient 1.8.9 e entre em um mundo.
3. Execute o injector e pressione **Insert** com o chat e os outros menus fechados.
4. Se existir uma configuração antiga, verifique se ela conserva outra tecla para `ClickGui`.

O Right Shift também é usado pelo OneConfig. Nesta base, a tecla padrão do CrewX é Insert.

## Encontrar o log sem Windows + R

Abra o Explorador de Arquivos, clique na barra de endereço e cole:

```text
%TEMP%\CrewX
```

Procure `crewx-inject.log`. Para falhas anteriores à inicialização Java, confira também os logs em `%TEMP%\CrewX21`.

## Interpretar as mensagens

| Mensagem | O que confirma |
| --- | --- |
| `CrewX initialized on client tick` | O código Java concluiu a inicialização naquele tick. |
| `ClickGui bind received` | A tecla configurada chegou ao caminho de abertura. |
| `ClickGui opening queued` | A abertura foi agendada para um próximo tick. |
| `ClickGui opening; style=` | A tentativa de criar a interface começou. |
| `ClickGui screen after open` | Mostra qual tela ficou selecionada. |
| `Modern ClickGui FAILED` / `Legacy ClickGui FAILED` | Registra a exceção da tentativa correspondente. |
| `onTickPre FAILED` / `onTickPost FAILED` | Um erro interrompeu o callback de tick. |
| `event handler FAILED` | Um handler de evento falhou. |

Uma inicialização bem-sucedida não comprova que a interface renderizou. A verificação estática também não comprova o funcionamento de todos os módulos.

## Abrir um relatório

Informe as versões do OneClient e do Java, a compilação do CrewX utilizada e os passos para reproduzir. Inclua o trecho relevante dos logs, removendo tokens, senhas e dados pessoais.
