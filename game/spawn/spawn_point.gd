class_name SpawnPoint
extends Marker3D
## Lugar onde o `Encounter` pai spawna um inimigo, parado e virado para a frente (-Z) deste
## marcador. Diz também quando o inimigo fica agressivo.

## Cena do inimigo (deve ter `Enemy` na raiz).
@export var enemy_scene: PackedScene
## Se true, o inimigo fica agressivo assim que aparece.
@export var aggro_on_spawn: bool = false
## Distância do alvo que deixa o inimigo agressivo (0 = só ao aparecer, se marcado, ou ao ser
## atingido).
@export var aggro_radius: float = 10.0
