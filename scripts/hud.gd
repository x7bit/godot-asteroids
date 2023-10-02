extends Control

var LifeScene: PackedScene = preload("res://scenes/life.tscn")

@onready var score_label: Label = $Score
@onready var lives_container: BoxContainer = $Lives
@onready var next_round: Control = $NextRound
@onready var round_label: Label = $NextRound/Round

func _ready():
	next_round.visible = false

func _process(_delta: float):
	pass

func update():
	score_label.text = "SCORE: " + str(Global.score)
	var lives_diff := Global.lives - lives_container.get_children().size()
	if lives_diff != 0:
		if lives_diff > 0:
			for i in lives_diff:
				lives_container.call_deferred("add_child", LifeScene.instantiate())
		else: #lives_diff < 0
			for i in -lives_diff:
				lives_container.get_children()[-i-1].queue_free()

func show_round():
	round_label.text = Global.game_round_label
	next_round.visible = true

func hide_round():
	next_round.visible = false
