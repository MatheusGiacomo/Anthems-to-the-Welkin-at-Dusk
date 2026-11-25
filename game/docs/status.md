# Status

## Onde paramos
- **MVP V1 (combate e jogabilidade) implementado.** Escopo no Notion (página MVP, seção v1). A arena (`arena/arena.tscn`, Main Scene) tem:
  - player com movimento por alinhamento, ataque (0,7/s), escudo com vida, parry e recarga, combo e vulnerabilidade;
  - capanga (aproximação, cautela com guarda que reflete, investida) e ladrão (besta, fuga ou luta com faca);
  - spawn por `SpawnPoint`, vida para todos e reinício da arena na morte do player;
  - painel de balanceamento (F3) e reaparição dos inimigos (F5).
- Regras e números: `docs/sistemas/` (`combate`, `movimento`, `inimigos`, `spawn`, `visual`); decisões 0015 (combate em modelos puros) e 0016 (IA por estados e cérebro). Todo número fictício está em `.tres`.
- Visual provisório com personagens animados do KayKit Adventurers 1.0 (CC0): cavaleiro (player), bárbaro com espada (capanga), Rogue com besta e faca (ladrão).
- Check completo: 108 testes, incluindo as restrições de balanceamento do MVP (`balance_invariants_test`).

## Próximo passo
- O desenvolvedor joga e valida o game feel: velocidade por alinhamento, janela de parry (0,5 s), leitura do preparo da investida (0,8 s, laranja), ritmo do combo e se a flecha dá para desviar.
- Pontos de balanceamento vistos na simulação: os três capangas investem sincronizados (mesmo `time_to_lunge`); depois de bater na guarda do capanga, o player tem só 0,3 s entre sair do atordoamento (1 s) e o golpe da investida (1,3 s).
- Receber o escopo do MVP v2 (no Notion: fluidez dos controles, um inimigo com IA realista, shader, props no mapa).

## Bloqueios
- Nenhum.

## Pendências
- Visual: animação de corpo inteiro (andar com o escudo erguido não move as pernas; resolver com `AnimationTree` e filtro de ossos); o capanga toca a defesa de escudo (`Block_Hit`) ao refletir golpes; o ladrão atordoado mostra a besta mesmo na luta de faca.
- Arco: o ladrão usa besta; o arco existe no KayKit Adventurers 2.0 (download manual no itch.io).
- Os testes de cena que seguram o escudo falharam uma vez num check completo (provável perda de foco da janela). Agora reafirmam a ação a cada quadro e contam as quedas na mensagem de falha; se voltar a falhar, investigar com essa contagem.
