//nutrition
/datum/mood_event/nutrition/fat
	description = "<span class='warning'><B>I feel like I'm gonna burst...</B></span>\n"
	mood_change = -4

/datum/mood_event/nutrition/fat/voracious
	description = span_nicegreen("Nothing like a good, hearty meal out here in the wastes!")
	mood_change = 4

/datum/mood_event/nutrition/wellfed
	description = span_nicegreen("I'm stuffed!")
	mood_change = 6

/datum/mood_event/nutrition/fed
	description = span_nicegreen("I have recently had some food.")
	mood_change = 3

/datum/mood_event/nutrition/hungry
	description = span_warning("I'm getting a bit hungry.")
	mood_change = -2

/datum/mood_event/nutrition/starving
	description = span_boldwarning("I'm starving!")
	mood_change = -4

//charge
/datum/mood_event/supercharged
	description = span_boldwarning("I can't possibly keep all this power inside, I need to release some quick!")
	mood_change = -10

/datum/mood_event/overcharged
	description = span_warning("I feel dangerously overcharged, perhaps I should release some power.")
	mood_change = -4

/datum/mood_event/charged
	description = span_nicegreen("I feel the power in my veins!")
	mood_change = 6

/datum/mood_event/lowpower
	description = span_warning("My power is running low, I should go charge up somewhere.")
	mood_change = -6

/datum/mood_event/decharged
	description = span_boldwarning("I'm in desperate need of some electricity!")
	mood_change = -10

//Disgust
/datum/mood_event/gross
	description = span_warning("I saw something gross.")
	mood_change = -2

/datum/mood_event/verygross
	description = span_warning("I think I'm going to puke...")
	mood_change = -5

/datum/mood_event/disgusted
	description = span_boldwarning("Oh god that's disgusting...")
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = span_warning("You smell something horribly decayed inside this room.")
	mood_change = -3

/datum/mood_event/disgust/nauseating_stench
	description = span_warning("The stench of rotting carcasses is unbearable!")
	mood_change = -7

//Generic needs events
/datum/mood_event/favorite_food
	description = span_nicegreen("I really enjoyed eating that.")
	mood_change = 3
	timeout = 2400

/datum/mood_event/gross_food
	description = span_warning("I really didn't like that food.")
	mood_change = -2
	timeout = 2400

/datum/mood_event/disgusting_food
	description = span_warning("That food was disgusting!")
	mood_change = -4
	timeout = 2400

/datum/mood_event/nice_shower
	description = span_nicegreen("I have recently had a nice shower.")
	mood_change = 2
	timeout = 3 MINUTES
