# Status

## Onde paramos
- **MVP V1 (combate e jogabilidade) implementado** e ajustado para um jogo mais rápido. Escopo no Notion (página MVP, seção v1).
- **Fluxo em fases** (Main Scene `levels/level_sequence.tscn`, decisão 0017): três cenas encadeadas com props placeholder (árvores e pedras de primitivas). O player entra pelo oeste, vence os inimigos e sai pelo leste; a saída só abre sem inimigos vivos; a troca escurece e clareia a tela; morrer recomeça a fase atual. Detalhes em `docs/sistemas/fases.md`. A arena plana ficou como cena de teste (`arena/arena.tscn`).
- **Controles:** WASD move e o player olha para onde anda; J ataca na direção em que ele está virado; K segura o escudo (o olhar trava, para recuar defendendo). Velocidade igual em qualquer direção.
- **Ritmo:** ataque do player a cada 0,8 s; investida do capanga depois de 0,8 s de cautela (ladrão com adaga, 0,6 s). Golpes corpo a corpo têm knockback leve (metade no escudo; nada no parry, no choque e nas flechas).
- **Câmera fixa** de frente, inclinada a 45°, enquadrando a cena inteira e refazendo o zoom quando a janela muda. Janela base 1920×1080, aberta maximizada e redimensionável.
- Onde ajustar cada número: tabela em `docs/sistemas/combate.md` ("Onde ajustar os números"). Todo número fictício está em `.tres` ou `@export`.
- Visual provisório com personagens animados do KayKit Adventurers 1.0 (CC0).
- Check completo: 115 testes.

## Próximo passo
- O desenvolvedor joga as três cenas e valida: girar para onde anda ao mirar o golpe, olhar travado com o escudo, força do knockback, ritmo mais rápido, leitura dos personagens com a câmera afastada.
- Trocar os props placeholder aos poucos, testando a jogabilidade.
- Plano separado para navegação dos inimigos (navmesh): hoje vão em linha reta e podem enroscar nos props.
- Receber o escopo do MVP v2 (no Notion: fluidez dos controles, um inimigo com IA realista, shader, props no mapa).

## Bloqueios
- Nenhum.

## Pendências
- Balanceamento: os capangas investem sincronizados (mesmo `time_to_lunge`); uma variação aleatória resolveria se ficar agressivo demais.
- Visual: animação de corpo inteiro (andar com o escudo erguido não move as pernas; resolver com `AnimationTree` e filtro de ossos); o capanga toca a defesa de escudo (`Block_Hit`) ao refletir golpes; o ladrão atordoado mostra a besta mesmo na luta de faca.
- Arco: o ladrão usa besta; o arco existe no KayKit Adventurers 2.0 (download manual no itch.io).
- Jogo embutido na aba Game do editor: o tamanho é o da aba, não o da janela configurada.
- Os testes de cena que seguram o escudo reafirmam a ação a cada quadro e contam as quedas na mensagem de falha (houve uma falha intermitente, provável perda de foco da janela); se voltar a falhar, investigar com essa contagem.
