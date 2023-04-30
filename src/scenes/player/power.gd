class_name PlayerPower

enum {
	GRAPPLE_KICK,
	GRAPPLE,
	DASH_KICK,
	DASH,
}


func human_readable(power):
	return PlayerPower.keys()[power].capitalize()


func loss_description(power):
	var description
	match power:
		GRAPPLE_KICK:
			description = "Your grapple no longer pulls you to the hook"
		GRAPPLE:
			description = "You can no longer use the grapple"
		DASH_KICK:
			description = "Pressing jump when dashing against surfaces no longer kicks off them"
		DASH:
			description = "You can no longer dash"
	return description
