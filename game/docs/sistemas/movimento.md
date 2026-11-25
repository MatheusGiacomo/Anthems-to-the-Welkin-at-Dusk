# Movimento

## Propósito
Andar com WASD relativo à câmera e olhar para onde anda. Golpe e escudo valem na direção em que
o player está virado.

## Componentes
- `player/player.gd` (`Player`): lê o input, pede o olhar e o movimento ao `LocomotionComponent`.
- `player/movement_rules.gd` (`MovementRules`): regra pura da direção relativa à câmera.
- `player/player_config.gd` + `player_config.tres` (`PlayerConfig`): velocidade, redutores e travas do olhar.
- `components/locomotion/locomotion_component.gd` (`LocomotionComponent`): aceleração e giro de um `CharacterBody3D`; usado também pelos inimigos.
- `camera/isometric_camera.gd` + `.tscn` (`IsometricCamera`): câmera ortográfica que segue o alvo e projeta o mouse no chão.

## Regras
- Corpos em `motion_mode` flutuante (visão de cima, sem gravidade): a velocidade é só horizontal.
- **Direção:** o input (`move_forward/back/left/right`) é girado pelo yaw da câmera, então W é sempre "para cima na tela".
- **Velocidade:** `move_speed` em qualquer direção, vezes `blocking_multiplier` com o escudo erguido e `attacking_multiplier` durante um ataque.
- A velocidade muda com `acceleration` (m/s²) do `LocomotionComponent`; o giro é limitado a `turn_speed_degrees` por segundo (0 = na hora).
- **Olhar:** o player gira para a direção em que anda; parado, mantém o olhar. Fica travado durante um ataque (`lock_facing_while_attacking`) e com o escudo erguido (`lock_facing_while_blocking`): assim anda de lado ou de costas defendendo.
- **Câmera:** ortográfica, `pitch_degrees` 35,264° (isométrico verdadeiro), `yaw_degrees` 45°, segue o alvo no ritmo da física com `follow_speed`.

## Sinais
Nenhum.

## Testes
- `test/unit/movement_rules_test.gd`: direção relativa à câmera.
- `test/scenes/player_movement_test.gd`: mesma velocidade para frente e de costas, o player vira para onde anda e não vira com o escudo erguido.
