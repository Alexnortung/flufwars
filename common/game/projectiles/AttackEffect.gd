class_name AttackEffect

enum attackEffectTypes {
    SPAWN_PROJECTILES,
    MELEE_ATTACK
}
var attackEffectType
var direction
var knockbackFactor
var data #dictionary

func _init(_attackEffectType, _direction, _knockbackFactor, _data):
    attackEffectType = _attackEffectType
    direction = _direction
    knockbackFactor = _knockbackFactor
    data = _data
