class_name UIHud extends Control

var LifeScene: PackedScene = preload("res://scenes/life.tscn")

@onready var score_label: Label = $ScoreLabel
@onready var lives_container: BoxContainer = $LivesContainer
@onready var round_control: Control = $Round
@onready var round_label: Label = $Round/RoundLabel
@onready var tip_control: Control = $Tip
@onready var tip_label: Label = $Tip/TipLabel

func _ready() -> void:
	round_control.visible = false
	tip_control.visible = false

func _process(_delta: float) -> void:
	pass

func update() -> void:
	score_label.text = "SCORE: " + str(Global.score)
	var lives_diff := Global.lives - lives_container.get_children().size()
	if lives_diff != 0:
		if lives_diff > 0:
			for i in lives_diff:
				lives_container.call_deferred("add_child", LifeScene.instantiate())
		else: #lives_diff < 0
			for i in -lives_diff:
				lives_container.get_children()[-i-1].queue_free()

func show_round() -> void:
	round_label.text = Global.game_round_label
	round_control.visible = true
	tip_control.visible = false

func hide_round() -> void:
	round_control.visible = false

func show_tip(text: String, color: Color) -> void:
	tip_label.text = text
	tip_label.set("theme_override_colors/font_color", color)
	tip_control.visible = true

func hide_tip() -> void:
	tip_control.visible = false
