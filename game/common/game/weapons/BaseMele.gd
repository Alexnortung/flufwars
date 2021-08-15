extends "res://common/game/weapons/BaseWeapon.gd"

func get_players_inside_hitbox():
	return $RotationCenter/Hitbox.get_overlapping_bodies()

func on_attack_effect() -> Array:
	if player == null:
		return []

	var arr = []
	
	for _player in get_players_inside_hitbox():
		if player.id == _player.id:
			continue
			
		var dir = (_player.position - player.position).normalized()
		var data = {
			player = _player,
		}
		var attackEffect = AttackEffect.new(AttackEffect.attackEffectTypes.MELEE_ATTACK, dir, knockbackFactor, damage, data)
		arr.append(attackEffect)

	return arr

# make players swing weapon
# detect if hitbox on weapon hit players
# apply damage and knockback

func animate_weapon(angle, lookDirectionX):
	.animate_weapon(angle, lookDirectionX)
	#$Hitbox.rotation = angle
