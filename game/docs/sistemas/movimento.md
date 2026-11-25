# Movimento

## Propósito
Andar com WASD relativo à câmera isométrica e olhar para o cursor do mouse, com velocidade que
depende do alinhamento entre o movimento e o olhar.

## Componentes
- `player/player.gd` (`Player`): lê o input, pede o olhar e o movimento ao `LocomotionComponent`.
- `player/movement_rules.gd` (`MovementRules`): regras puras do multiplicador por alinhamento e da direção relativa à câmera.
- `player/player_config.gd` + `player_config.tres` (`PlayerConfig`): velocidade e multiplicadores.
- `components/locomotion/locomotion_component.gd` (`LocomotionComponent`): aceleração e giro de um `CharacterBody3D`; usado também pelos inimigos.
- `camera/isometric_camera.gd` + `.tscn` (`IsometricCamera`): câmera ortográfica que segue o alvo e projeta o mouse no chão.

## Regras
- Corpos em `motion_mode` flutuante (visão de cima, sem gravidade): a velocidade é só horizontal.
- **Direção:** o input (`move_forward/back/left/right`) é girado pelo yaw da câmera, então W é sempre "para cima na tela".
- **Velocidade:** `move_speed × multiplicador de alinhamento`. O multiplicador vai linearmente de `backward_multiplier` (de costas) a `forward_multiplier` (para onde olha), pelo cosseno do ângulo entre o movimento e o olhar; de lado, vale a média.
- A velocidade muda com `acceleration` (m/s²) do `LocomotionComponent`; o giro é limitado a `turn_speed_degrees` por segundo (0 = na hora).
- **Olhar:** o player gira para o ponto do chão (na altura dele) sob o cursor.
- **Câmera:** ortográfica, `pitch_degrees` 35,264° (isométrico verdadeiro), `yaw_degrees` 45°, segue o alvo no ritmo da física com `follow_speed`.
- Multiplicadores de escudo e ataque: ver `combate.md` e a seção do player em `PlayerConfig`.

## Sinais
Nenhum.

## Testes
- `test/unit/movement_rules_test.gd`: multiplicador nos extremos, de lado, monotonia e direção relativa à câmera.
- `test/scenes/player_movement_test.gd`: na cena, a velocidade para frente e de costas fica na faixa esperada.
