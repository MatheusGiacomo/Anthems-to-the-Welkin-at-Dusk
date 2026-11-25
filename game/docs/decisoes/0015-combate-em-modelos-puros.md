# 0015 — Combate em modelos puros com resolução central dos golpes

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O MVP V1 tem regras de combate com muitos casos cruzados (escudo com vida, parry por timing,
guarda que reflete, choque de espadas, combo por vulnerabilidade) e todos os números são
fictícios, para balancear depois. Player e inimigos precisam das mesmas regras. Espalhar as
decisões pelos scripts de cada entidade duplicaria a lógica e deixaria os casos sem teste.

## Decisão
- Cada regra com estado vive num modelo `RefCounted` sem dependência da árvore (`VulnerabilityModel`, `GuardModel`, `AttackCycle`), avançado por `tick(delta)`. Um componente-nó fino o envolve, lê a config (`Resource`) e emite sinais.
- O resultado de um golpe é decidido num só lugar, `HitResolver.resolve(attack, defense)`, função pura sobre o ataque e uma fotografia do defensor (`DefenseState`).
- A HurtBox monta a fotografia, resolve e aplica o efeito no defensor; a HitBox aplica o efeito no atacante a partir do resultado devolvido. Nenhum dos dois conhece o script do dono.
- O escudo é verificado por arco em relação à frente da entidade, não por um colisor próprio.

## Alternativas descartadas
- **Regras dentro dos componentes-nó**: testáveis só com cena e `_physics_process`, mais lentos e frágeis.
- **Colisor físico para o escudo**: depende da malha e de ordem de detecção; golpes rápidos podem atravessar. O arco é determinístico e testável.

## Consequências
Todos os casos do combate têm teste unitário, e um tipo de ataque novo é só um `AttackData`
novo. Regras novas que dependem do defensor entram como campo do `DefenseState` e caso do
`HitResolver`. Em troca, há um arquivo a mais por regra (modelo e componente).
