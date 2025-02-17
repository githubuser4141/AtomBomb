#define BODYPART_MISSING "LIMB GONE"
#define BODYPART_INORGANIC "LIMB BAD"
#define CARBON_ISNT "NOT CARBON"
#define UNABLE_TO_HEAL 0
#define BODYPART_FINE 0
#define DO_HEAL_DAMAGE (1<<1)
#define DO_UNBLEED_WOUND (1<<2)
#define DO_UNBURN_WOUND (1<<3)
#define DO_APPLY_BANDAGE (1<<4)

/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 12
	max_amount = 12
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/medical
	/// We have an active do_after, dont superstack healing things
	var/is_healing = FALSE
	var/self_penalty_effectiveness = 0.8
	var/self_delay = 50
	var/other_delay = 0
	var/repeating = TRUE
	/// How much brute we heal per application
	var/heal_brute
	/// How much burn we heal per application
	var/heal_burn
	/// How much we reduce bleeding per application on cut wounds
	var/stop_bleeding
	/// How much sanitization to apply to burns on application
	var/sanitization
	/// How much we add to flesh_healing for burn wounds on application
	var/flesh_regeneration
	/// Can this heal critters?
	var/can_heal_critters = TRUE

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	. = ..()
	INVOKE_ASYNC(src, .proc/try_heal, M, user)

/obj/item/stack/medical/proc/try_heal(mob/living/M, mob/user, silent = FALSE)
	if(heal(M, user))
		log_combat(user, M, "healed", src.name)
		use(1)
		if(repeating && amount > 0)
			try_heal(M, user, TRUE)

/obj/item/stack/medical/proc/heal(mob/living/M, mob/user)
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, 0)
	if(isanimal(M) && can_heal_critters)
		return heal_critter(M, user)
	to_chat(user, span_warning("You can't heal [M] with \the [src]!"))

/obj/item/stack/medical/proc/heal_critter(mob/living/M, mob/user)
	if(!isanimal(M))
		return
	var/mob/living/simple_animal/critter = M
	if(M.stat == DEAD)
		to_chat(user, span_notice(" [M] is dead. You can not help [M.p_them()]!"))
		return 
	if (!(critter.healable))
		to_chat(user, span_warning("[M] cannot be healed!"))
		return FALSE
	else if (critter.health == critter.maxHealth)
		to_chat(user, span_notice("[M] is at full health."))
		return FALSE
	user.visible_message(span_green("[user] applies \the [src] on [M]."), span_green("You apply \the [src] on [M]."))
	M.heal_bodypart_damage(heal_brute)
	return TRUE

/obj/item/stack/medical/proc/heal_carbon(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !user)
		return FALSE
	if(is_healing)
		user.show_message(span_alert("You're already doing something with this!"))
		return
	if(!user.can_inject(C, TRUE))
		return
	
	var/list/heal_operations = pick_a_bodypart(C, user)
	if(!islist(heal_operations))
		to_chat(user, span_phobia("Uh oh! [src] didnt return a list! This is a bug, probably! Report this pls~ =3"))
		return FALSE
	if(!istype(heal_operations["bodypart"], /obj/item/bodypart))
		if(heal_operations["bodypart"] == UNABLE_TO_HEAL)
			to_chat(user, span_warning("[C] wouldn't really benefit from \the [src]!"))
			return FALSE
		else
			to_chat(user, span_phobia("Uh oh! [src] somehow returned something that wasnt a bodypart! This is a bug, probably! Report this pls~ =3"))
			return FALSE

	var/self_application = (user == C)
	var/obj/item/bodypart/affected_bodypart = heal_operations["bodypart"]
	do_medical_message(user, C, "start")
	is_healing = TRUE
	if(!do_mob(user, C, (self_application ? self_delay : other_delay), progress = TRUE))
		to_chat(user, span_warning("You were interrupted!"))
		is_healing = FALSE
		return
	is_healing = FALSE
	/// now we start doing healy things!
	if(heal_operations & DO_HEAL_DAMAGE)
		if(affected_bodypart.heal_damage(heal_brute, heal_burn))
			C.update_damage_overlays()
	if(heal_operations & DO_UNBLEED_WOUND)
		for(var/datum/wound/wounds_to_unbleed in affected_bodypart.wounds)
			if(wounds_to_unbleed.blood_flow)
				wounds_to_unbleed.treat_bleed(src, user, self_application)
				break
	if(heal_operations & DO_UNBURN_WOUND)
		for(var/datum/wound/burn/wounds_to_unburn in affected_bodypart.wounds)
			if(wounds_to_unburn.flesh_damage || wounds_to_unburn.infestation)
				wounds_to_unburn.treat_burn(src, user, self_application)
				break
	/* if(heal_operations & DO_APPLY_BANDAGE)
		affected_bodypart.apply_gauze(src) */

	do_medical_message(user, C, "end")
	return TRUE


/// Checks the limb for things we can do to it
/// Returns a string if the limb is certainly not suitable for healing
/// Returns a bitfield if the limb can be healed
/// Returns 0 if the limb just doesnt need healing
/obj/item/stack/medical/proc/check_bodypart(mob/living/carbon/C, obj/item/bodypart/target_bodypart, output_message = FALSE)
	if(!iscarbon(C))
		return output_message ? CARBON_ISNT : UNABLE_TO_HEAL
	if(!target_bodypart || !istype(target_bodypart, /obj/item/bodypart))
		return output_message ? BODYPART_MISSING : UNABLE_TO_HEAL
	if(target_bodypart.status != BODYPART_ORGANIC)
		return output_message ? BODYPART_INORGANIC : UNABLE_TO_HEAL
	/// Okay we can reasonably assume this limb is okay to try and treat
	. = BODYPART_FINE
	if(heal_brute && target_bodypart.brute_dam || heal_burn && target_bodypart.burn_dam)
		. |= DO_HEAL_DAMAGE
	for(var/datum/wound/woundies in target_bodypart.wounds)
		//if(absorption_rate || absorption_capacity)
		//	 if(woundies.wound_flags & ACCEPTS_GAUZE)
		//		. |= DO_APPLY_BANDAGE
		if(stop_bleeding)
			if(woundies.blood_flow)
				. |= DO_UNBLEED_WOUND
	for(var/datum/wound/burn/burndies in target_bodypart.wounds)
		if(sanitization || flesh_regeneration)
			if(burndies.flesh_damage || burndies.infestation)
				. |= DO_UNBURN_WOUND

/// Returns a bodypart and a bitfield in a list with the first valid bodypart we can work on
/// Returns just a number (FALSE) if nothing is found
/obj/item/stack/medical/proc/pick_a_bodypart(mob/living/carbon/C, mob/user)
	var/obj/item/bodypart/first_choice = C.get_bodypart(check_zone(user.zone_selected))
	var/do_these_things = check_bodypart(C, first_choice, TRUE)
	var/list/output_heal_instructions = list("bodypart" = UNABLE_TO_HEAL, "operations" = UNABLE_TO_HEAL)
	// shouldnt happen, but just in case
	if(do_these_things == CARBON_ISNT)
		to_chat(user, span_warning("That can't be healed with this!"))
		return output_heal_instructions

	// limb is missing, output a message and move on
	if(do_these_things == BODYPART_MISSING)
		to_chat(user, span_warning("[C] doesn't have \a [parse_zone(user.zone_selected)]! Let's try another part..."))

	// limb is missing, output a message and move on
	if(do_these_things == BODYPART_INORGANIC)
		to_chat(user, span_warning("[C]'s [parse_zone(user.zone_selected)] is robotic! Let's try another part..."))
	
	// If our operations are a number, and that number corresponds to operations to do, good! output what we're working on and what to do
	if(isnum(do_these_things) && do_these_things > BODYPART_FINE)
		output_heal_instructions = list("bodypart" = first_choice, "operations" = do_these_things)
		return output_heal_instructions
	
	// Part wasn't there, or needed no healing. Lets find one that does need healing!
	var/obj/item/bodypart/affecting
	for(var/limb_slot_to_check in GLOB.main_body_parts)
		if(limb_slot_to_check == user.zone_selected)
			continue // We already checked this, dont check again
		affecting = C.get_bodypart(check_zone(limb_slot_to_check))
		do_these_things = check_bodypart(C, affecting)
		if(isnum(do_these_things) && do_these_things > BODYPART_FINE)
			return output_heal_instructions = list("bodypart" = affecting, "operations" = do_these_things)
	return output_heal_instructions

/obj/item/stack/medical/proc/do_medical_message(mob/user, mob/target, which_message)
	if(!user || !target)
		return
	switch(which_message)
		if("start")
			user.visible_message(
				span_warning("[user] begins applying \a [src] to [target]'s wounds..."), 
				span_warning("You begin applying \a [src] to [user == target ? "your" : "[target]'s"] wounds..."))

		if("end")
			user.visible_message(
				span_green("[user] applies \a [src] to [target]'s wounds.</span>"), 
				span_green("You apply \a [src] to [user == target ? "your" : "[target]'s"] wounds."))

/obj/item/stack/medical/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "pouch")

///Override this proc for special post heal effects.
/obj/item/stack/medical/proc/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	return

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	self_delay = 40
	other_delay = 20
	grind_results = list(/datum/reagent/medicine/styptic_powder = 10)
	merge_type = /obj/item/stack/medical/bruise_pack

/obj/item/stack/medical/bruise_pack/one
	amount = 1

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth. Use it to staunch and heal bleeding and burns, and treat infection."
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	heal_brute = 5
	self_delay = 20
	other_delay = 10
	amount = 10
	max_amount = 10
	absorption_rate = 0.45
	absorption_capacity = 10
	stop_bleeding = 3
	splint_factor = 0.35
	custom_price = PRICE_REALLY_CHEAP
	grind_results = list(/datum/reagent/cellulose = 2)
	merge_type = /obj/item/stack/medical/gauze

/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.get_sharpness())
		if(get_amount() < 2)
			to_chat(user, span_warning("You need at least two gauzes to do this!"))
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("[user] cuts [src] into pieces of cloth with [I].", \
					span_notice("You cut [src] into pieces of cloth with [I]."), \
					span_italic("You hear cutting."))
		use(2)
	else if(I.is_drainable() && I.reagents.has_reagent(/datum/reagent/abraxo_cleaner/sterilizine))
		if(!I.reagents.has_reagent(/datum/reagent/abraxo_cleaner/sterilizine, 10))
			to_chat(user, span_warning("There's not enough sterilizine in [I] to sterilize [src]!"))
			return
		user.visible_message(span_notice("[user] pours the contents of [I] onto [src], sterilizing it."), span_notice("You pour the contents of [I] onto [src], sterilizing it."))
		I.reagents.remove_reagent(/datum/reagent/abraxo_cleaner/sterilizine, 10)
		new /obj/item/stack/medical/gauze/adv/one(user.drop_location())
		use(1)
	else
		return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins tightening \the [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!"))
	return OXYLOSS

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	icon_state = "makeshift_gauze"
	heal_brute = 3
	desc = "A roll of cloth. Useful for staunching bleeding, healing burns, and reversing infection, but not THAT useful."
	self_delay = 20
	other_delay = 5
	absorption_rate = 0.15
	absorption_capacity = 4
	stop_bleeding = 2
	merge_type = /obj/item/stack/medical/gauze/improvised

/obj/item/stack/medical/gauze/improvised/microwave_act(obj/machinery/microwave/MW)
	..()
	new /obj/item/stack/medical/gauze(drop_location(), amount)
	qdel(src)

/obj/item/stack/medical/gauze/adv
	name = "sterilized medical gauze"
	singular_name = "sterilized medical gauze"
	desc = "A roll of elastic sterilized cloth that is extremely effective at stopping bleeding and covering burns. "
	icon_state = "sterilized_gauze"
	heal_brute = 5
	self_delay = 20
	other_delay = 10
	stop_bleeding = 4
	absorption_rate = 0.4
	absorption_capacity = 15
	merge_type = /obj/item/stack/medical/gauze/adv

/obj/item/stack/medical/gauze/adv/one
	amount = 1

/obj/item/stack/medical/gauze/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 250
	merge_type = /obj/item/stack/medical/gauze/cyborg

/obj/item/stack/medical/suture
	name = "suture"
	desc = "Basic sterile sutures used to seal up cuts and lacerations and stop bleeding."
	gender = PLURAL
	singular_name = "suture"
	icon_state = "suture"
	self_delay = 50
	other_delay = 10
	amount = 15
	max_amount = 15
	heal_brute = 10
	stop_bleeding = 4
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)
	merge_type = /obj/item/stack/medical/suture

/obj/item/stack/medical/suture/one
	amount = 1

/obj/item/stack/medical/suture/five
	amount = 5

/obj/item/stack/medical/suture/emergency
	name = "improvised suture"
	icon_state = "suture_imp"
	desc = "A set of improvised sutures consisting of clothing thread and a sewing needle, not very good at repairing damage, but still decent at stopping bleeding."
	heal_brute = 5
	amount = 5
	max_amount = 15
	stop_bleeding = 3
	merge_type = /obj/item/stack/medical/suture/emergency

/obj/item/stack/medical/suture/emergency/five
	amount = 5

/obj/item/stack/medical/suture/emergency/ten
	amount = 10

/obj/item/stack/medical/suture/emergency/fifteen
	amount = 15

/obj/item/stack/medical/suture/medicated
	name = "medicated suture"
	icon_state = "suture_purp"
	desc = "A suture infused with drugs that speed up wound healing of the treated laceration."
	heal_brute = 15
	stop_bleeding = 8
	grind_results = list(/datum/reagent/medicine/polypyr = 2)
	merge_type = /obj/item/stack/medical/suture/medicated

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Basic burn ointment, rated effective for second degree burns with proper bandaging. Not very effective at treating infection, but better than nothing. USE WITH A BANDAGE."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount = 12
	max_amount = 12
	self_delay = 40
	other_delay = 20
	merge_type = /obj/item/stack/medical/ointment

	heal_burn = 5
	flesh_regeneration = 7
	sanitization = 2
	grind_results = list(/datum/reagent/medicine/kelotane = 10)

/obj/item/stack/medical/ointment/five
	amount = 5

/obj/item/stack/medical/ointment/twelve
	amount = 12

/obj/item/stack/medical/ointment/heal(mob/living/M, mob/user)
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn)
	to_chat(user, span_warning("You can't heal [M] with \the [src]!"))

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is squeezing \the [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is toxic?"))
	return TOXLOSS

/obj/item/stack/medical/mesh
	name = "regenerative mesh"
	desc = "An advanced bacteriostatic mesh used to dress burns and sanitize burns. Also removes infection directly, unlike ointment. Best for severe burns. This is the kind of thing you would expect to see in a pre-war hospital."
	gender = PLURAL
	singular_name = "regenerative mesh"
	icon_state = "regen_mesh"
	self_delay = 30
	other_delay = 10
	amount = 15
	max_amount = 15
	heal_burn = 10
	sanitization = 2
	flesh_regeneration = 6
	var/is_open = TRUE ///This var determines if the sterile packaging of the mesh has been opened.
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)
	merge_type = /obj/item/stack/medical/mesh

/obj/item/stack/medical/mesh/one
	amount = 1

/obj/item/stack/medical/mesh/five
	amount = 5

/obj/item/stack/medical/mesh/advanced
	name = "advanced regenerative mesh"
	desc = "An advanced mesh made with aloe extracts and sterilizing chemicals, used for the most critical burns. Also removes infection directly, unlike ointment. This is the kind of thing you would expect to see in a pre-war hospital for rich people."
	gender = PLURAL
	singular_name = "advanced regenerative mesh"
	icon_state = "aloe_mesh"
	heal_burn = 15
	sanitization = 6
	flesh_regeneration = 12
	grind_results = list(/datum/reagent/consumable/aloejuice = 1)
	merge_type = /obj/item/stack/medical/mesh/advanced

/obj/item/stack/medical/mesh/advanced/one
	amount = 1

/obj/item/stack/medical/mesh/Initialize()
	. = ..()
	if(amount == max_amount)	 //only seal full mesh packs
		is_open = FALSE
		update_icon()

/obj/item/stack/medical/mesh/advanced/update_icon_state()
	if(!is_open)
		icon_state = "aloe_mesh_closed"
	else
		return ..()

/obj/item/stack/medical/mesh/update_icon_state()
	if(!is_open)
		icon_state = "regen_mesh_closed"
	else
		return ..()

/obj/item/stack/medical/mesh/try_heal(mob/living/M, mob/user, silent = FALSE)
	if(!is_open)
		to_chat(user, span_warning("You need to open [src] first."))
		return
	. = ..()

/obj/item/stack/medical/mesh/AltClick(mob/living/user)
	if(!is_open)
		to_chat(user, span_warning("You need to open [src] first."))
		return
	. = ..()

/obj/item/stack/medical/mesh/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	if(!is_open && user.get_inactive_held_item() == src)
		to_chat(user, span_warning("You need to open [src] first."))
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_self(mob/user)
	if(!is_open)
		is_open = TRUE
		to_chat(user, span_notice("You open the sterile mesh package."))
		update_icon()
		playsound(src, 'sound/items/poster_ripped.ogg', 20, TRUE)
		return
	. = ..()

/obj/item/stack/medical/bone_gel
	name = "bone gel"
	singular_name = "bone gel"
	desc = "A potent medical gel that, when applied to a damaged bone in a proper surgical setting, triggers an intense melding reaction to repair the wound. Can be directly applied alongside surgical sticky tape to a broken bone in dire circumstances, though this is very harmful to the patient and not recommended."

	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	amount = 4
	self_delay = 20
	grind_results = list(/datum/reagent/medicine/bicaridine = 10)
	novariants = TRUE

/obj/item/stack/medical/bone_gel/attack(mob/living/M, mob/user)
	to_chat(user, span_warning("Bone gel can only be used on fractured limbs while aggressively holding someone!"))
	return

/obj/item/stack/medical/bone_gel/suicide_act(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.visible_message(span_suicide("[C] is squirting all of \the [src] into [C.p_their()] mouth! That's not proper procedure! It looks like [C.p_theyre()] trying to commit suicide!"))
		if(do_after(C, 2 SECONDS))
			C.emote("scream")
			for(var/i in C.bodyparts)
				var/obj/item/bodypart/bone = i
				var/datum/wound/blunt/severe/oof_ouch = new
				oof_ouch.apply_wound(bone)
				var/datum/wound/blunt/critical/oof_OUCH = new
				oof_OUCH.apply_wound(bone)

			for(var/i in C.bodyparts)
				var/obj/item/bodypart/bone = i
				bone.receive_damage(brute=60)
			use(1)
			return (BRUTELOSS)
		else
			C.visible_message(span_suicide("[C] screws up like an idiot and still dies anyway!"))
			return (BRUTELOSS)

/obj/item/stack/medical/bone_gel/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 250
	merge_type = /obj/item/stack/medical/bone_gel/cyborg

/obj/item/stack/medical/mesh/aloe
	name = "aloe cream"
	desc = "A healing paste you can apply on wounds."

	icon_state = "aloe_paste"
	self_delay = 20
	other_delay = 10
	novariants = TRUE
	heal_burn = 10
	amount = 20
	max_amount = 20
	grind_results = list(/datum/reagent/consumable/aloejuice = 1)

/obj/item/stack/medical/mesh/aloe/Initialize()
	. = ..()
	if(amount == max_amount)	 //aloe starts open lol
		is_open = TRUE
		update_icon()


// ------------------
// MOURNING DUST   (should be repathed to be less misleading at some point)
// ------------------

/obj/item/stack/medical/poultice
	name = "mourning dust"
	singular_name = "mourning dust"
	desc = "A type of primitive herbal powder.\nWhile traditionally used to prepare corpses for the mourning feast, it can also treat scrapes and burns on the living, however, it is liable to cause shortness of breath when employed in this manner.\nIt is imbued with ancient wisdom."
	icon = 'icons/fallout/objects/medicine/drugs.dmi'
	icon_state = "mourningdust"
	amount = 15
	max_amount = 15
	heal_brute = 10
	heal_burn = 10
	self_delay = 40
	other_delay = 10
	merge_type = /obj/item/stack/medical/poultice
	novariants = TRUE

/obj/item/stack/medical/poultice/ten
	amount = 10

/obj/item/stack/medical/poultice/five
	amount = 5

/obj/item/stack/medical/poultice/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	healed_mob.adjustOxyLoss(amount_healed)

/datum/chemical_reaction/mourningpoultice
	name = "mourning dust"
	id = "mourningdust"
	required_reagents = list(/datum/reagent/consumable/tea/coyotetea = 10, /datum/reagent/cellulose = 20, /datum/reagent/consumable/tea/feratea = 10)
	mob_react = FALSE

/datum/chemical_reaction/mourningpoultice/on_reaction(datum/reagents/holder, multiplier)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= multiplier, i++)
		new /obj/item/stack/medical/poultice/five(location)
