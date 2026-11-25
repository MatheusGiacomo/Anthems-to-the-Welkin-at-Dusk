# 0016 — IA de inimigos por estados reutilizáveis e um cérebro por inimigo

- **Data**: 2026-11
- **Status**: aceita

## Contexto
Os inimigos do MVP V1 compartilham comportamentos: o ladrão, quando luta com a adaga, assume a
IA do capanga (cautela e investida). Inimigos futuros também vão repetir partes (aproximar,
fugir, ficar atordoado). A IA precisa ser legível, testável e permitir montar um inimigo novo
juntando comportamentos que já existem.

## Decisão
- Máquina de estados em nós (`components/state_machine/`): cada estado é um nó filho (`State`), com `enter`, `exit` e `physics_update`.
- Os estados dos inimigos (`enemies/states/`) fazem **um** comportamento e não conhecem os outros. Quando terminam algo, emitem `finished(motivo)`.
- Cada inimigo tem um **cérebro** (`EnemyBrain` e uma subclasse por inimigo) que é a própria máquina: escolhe as transições. As decisões ficam em funções puras (`*_rules.gd`), testadas em `test/unit/`.
- O `EnemyBrain` base cuida do que é comum: alvo (`aggro`/`calm`), vulnerabilidade (entra no estado atordoado e sai dele) e o contexto compartilhado (`AgentContext`: corpo, movimento, alvo).
- Os valores de cada comportamento ficam num `Resource` (`.tres`) por perfil (ex.: espada do capanga, adaga do ladrão).

## Alternativas descartadas
- **Addon de behavior tree (LimboAI, Beehave)**: dependência nova em `addons/` para IAs de três ou quatro estados.
- **Um script de IA por inimigo com `match`**: o ladrão repetiria a cautela e a investida do capanga.

## Consequências
Um inimigo novo é uma cena que junta estados existentes e um cérebro pequeno com as regras de
transição dele. Mudar uma transição é mexer numa função pura testada. Em troca, há mais nós na
cena e a fiação entre estados e componentes é feita no editor (decisão 0006).
