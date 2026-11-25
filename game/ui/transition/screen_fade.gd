class_name ScreenFade
extends CanvasLayer
## Tela preta que escurece e clareia por cima do jogo, para trocar de cena sem corte seco. As
## duas transições podem ser aguardadas (`await fade.fade_out()`).

## Segundos para escurecer.
@export var fade_out_time: float = 0.4
## Segundos para clarear.
@export var fade_in_time: float = 0.4

@onready var _cover: ColorRect = $Cover


## Deixa a tela preta na hora (para começar escuro e clarear).
func set_black() -> void:
	_cover.modulate.a = 1.0


## Escurece até a tela ficar preta; termina quando acaba.
func fade_out() -> void:
	await _fade_to(1.0, fade_out_time)


## Clareia até a tela aparecer inteira; termina quando acaba.
func fade_in() -> void:
	await _fade_to(0.0, fade_in_time)


## Leva a opacidade da tela preta até `alpha` em `duration` segundos.
func _fade_to(alpha: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_cover, "modulate:a", alpha, duration)
	await tween.finished
