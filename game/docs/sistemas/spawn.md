# Spawn

## Propósito
Colocar inimigos na cena a partir de marcadores e decidir quando eles ficam agressivos.

## Componentes
- `spawn/spawn_point.gd` (`SpawnPoint`, Marker3D): onde e qual inimigo spawnar (`enemy_scene`) e quando ele fica agressivo (`aggro_on_spawn`, `aggro_radius`).
- `spawn/encounter.gd` (`Encounter`, Node3D): spawna um inimigo em cada `SpawnPoint` filho, cuida da agressão por proximidade e conta os vivos. Os inimigos e os projéteis deles ficam como filhos do encontro.
- As duas funções essenciais de uma unidade ficam no `Enemy`: `spawn(transform)` (coloca parada no lugar, sem alvo) e `aggro(target)` (define o alvo e liga a IA).

## Regras
- `spawn_all()`: para cada `SpawnPoint` com cena, instancia o inimigo (nomeado `<ponto>Enemy`), coloca-o parado na posição e na direção (-Z) do ponto e registra o raio de agressão.
- **Agressão**: na hora, se `aggro_on_spawn`; quando o alvo entra em `aggro_radius` (0 desliga); ou quando o inimigo é atingido (contra quem bateu, regra do `Enemy`).
- `respawn_all()`: remove inimigos e projéteis e spawna de novo. Na arena, tecla F5 (`debug_respawn_enemies`).
- `calm_all()`: todos largam o alvo e a agressão por proximidade é desligada (o alvo vira nulo).
- `all_enemies_died` é emitido quando morre o último inimigo vivo (remover com `clear` não conta).
- Arena do V1 (`arena/arena.tscn`): três capangas (raio 10 m) e dois ladrões (raio 15 m), todos virados para o centro, onde o player começa.

## Sinais
- `Encounter.enemy_spawned(enemy)`, `all_enemies_died`.
- `Enemy.died` → `Encounter._on_enemy_died`.

## Testes
- `test/scenes/encounter_test.gd`: spawn parado em cada ponto, agressão pela proximidade, reaparição.
