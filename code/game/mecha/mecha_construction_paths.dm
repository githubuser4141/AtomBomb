////////////////////////////////
///// Construction datums //////
////////////////////////////////
/datum/component/construction/mecha
	var/base_icon
	var/looky_helpy = TRUE

/datum/component/construction/mecha/examine(datum/source, mob/user, list/examine_list)
	. = ..()
	if(looky_helpy)
		switch(steps[index]["key"])
			if(TOOL_WRENCH)
				examine_list += "<span class='notice'>The mech could be <b>wrenched</b> into place.</span>"
			if(TOOL_SCREWDRIVER)
				examine_list += "<span class='notice'>The mech could be <b>screwed</b> into place.</span>"
			if(TOOL_WIRECUTTER)
				examine_list += "<span class='notice'>The mech wires could be <b>trimmed</b> into place.</span>"
			if(/obj/item/stack/cable_coil)
				examine_list += "<span class='notice'>The mech could use some <b>wiring</b>.</span>"
			if(/obj/item/circuitboard)
				examine_list += "<span class='notice'>The mech could use a type of<b>circuitboard</b>.</span>"
			if(/obj/item/stock_parts/scanning_module)
				examine_list += "<span class='notice'>The mech could use a <b>scanning stock part</b>.</span>"
			if(/obj/item/stock_parts/capacitor)
				examine_list += "<span class='notice'>The mech could use a <b>power based stock part</b>.</span>"
			if(/obj/item/stock_parts/cell)
				examine_list += "<span class='notice'>The mech could use a <b>power source</b>.</span>"
			if(/obj/item/stack/sheet/metal)
				examine_list += "<span class='notice'>The mech could use some <b>sheets of metal</b>.</span>"
			if(/obj/item/stack/sheet/plasteel)
				examine_list += "<span class='notice'>The mech could use some <b>sheets of strong steel</b>.</span>"
			if(/obj/item/mecha_parts/part)
				examine_list += "<span class='notice'>The mech could use a mech <b>part</b>.</span>"
			if(/obj/item/stack/ore/bluespace_crystal)
				examine_list += "<span class='notice'>The mech could use a <b>crystal</b> of sorts.</span>"
			if(/obj/item/assembly/signaler/anomaly)
				examine_list += "<span class='notice'>The mech could use a <b>anomaly</b> of sorts.</span>"

/datum/component/construction/mecha/spawn_result()
	if(!result)
		return
	// Remove default mech power cell, as we replace it with a new one.
	var/obj/vehicle/sealed/mecha/M = new result(drop_location())
	QDEL_NULL(M.cell)

	var/obj/item/mecha_parts/chassis/parent_chassis = parent
	M.CheckParts(parent_chassis.contents)

	SSblackbox.record_feedback("tally", "mechas_created", 1, M.name)
	QDEL_NULL(parent)

/datum/component/construction/mecha/update_parent(step_index)
	..()
	// By default, each step in mech construction has a single icon_state:
	// "[base_icon][index - 1]"
	// For example, Ripley's step 1 icon_state is "ripley0".
	var/atom/parent_atom = parent
	if(!steps[index]["icon_state"] && base_icon)
		parent_atom.icon_state = "[base_icon][index - 1]"

/datum/component/construction/unordered/mecha_chassis/custom_action(obj/item/I, mob/living/user, typepath)
	. = user.transferItemToLoc(I, parent)
	if(.)
		var/atom/parent_atom = parent
		user.visible_message("[user] has connected [I] to [parent].", span_notice("You connect [I] to [parent]."))
		parent_atom.add_overlay(I.icon_state+"+o")
		qdel(I)

/datum/component/construction/unordered/mecha_chassis/spawn_result()
	var/atom/parent_atom = parent
	parent_atom.icon = 'icons/mecha/mech_construction.dmi'
	parent_atom.density = TRUE
	parent_atom.cut_overlays()
	..()


/datum/component/construction/unordered/mecha_chassis/ripley
	result = /datum/component/construction/mecha/ripley
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg
	)

/datum/component/construction/mecha/ripley
	result = /obj/vehicle/sealed/mecha/working/ripley
	base_icon = "ripley"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/ripley/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/ripley/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The scanner module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//15
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//16
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//17
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//18
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//19
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//20
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/component/construction/mecha/ripley/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures [I].", span_notice("You secure [I]."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I].", span_notice("You install [I]."))
			else
				user.visible_message("[user] unsecures the capacitor from [parent].", span_notice("You unsecure the capacitor from [parent]."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external reinforced armor layer to [parent].", span_notice("You install the external reinforced armor layer to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", span_notice("You secure the external reinforced armor layer."))
			else
				user.visible_message("[user] pries external armor layer from [parent].", span_notice("You pry external armor layer from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to [parent].", span_notice("You weld the external armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the external armor layer.", span_notice("You unfasten the external armor layer."))
	return TRUE

/datum/component/construction/unordered/mecha_chassis/gygax
	result = /datum/component/construction/mecha/gygax
	steps = list(
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_head
	)

/datum/component/construction/mecha/gygax
	result = /obj/vehicle/sealed/mecha/combat/gygax
	base_icon = "gygax"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//16
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//17
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//18
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//19
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//20
		list(
			"key" = /obj/item/mecha_parts/part/gygax_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),

	)

/datum/component/construction/mecha/gygax/action(datum/source, atom/used_atom, mob/user)
	return check_step(used_atom,user)

/datum/component/construction/mecha/gygax/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", span_notice("You secure the weapon control module."))
			else
				user.visible_message("[user] removes the weapon control module from [parent].", span_notice("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the weapon control module.", span_notice("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", span_notice("You secure the capacitor."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the capacitor.", span_notice("You unfasten the capacitor."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures Gygax Armor Plates.", span_notice("You secure Gygax Armor Plates."))
			else
				user.visible_message("[user] pries Gygax Armor Plates from [parent].", span_notice("You pry Gygax Armor Plates from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds Gygax Armor Plates to [parent].", span_notice("You weld Gygax Armor Plates to [parent]."))
			else
				user.visible_message("[user] unfastens Gygax Armor Plates.", span_notice("You unfasten Gygax Armor Plates."))
	return TRUE

//Begin Medigax
/datum/component/construction/unordered/mecha_chassis/medigax
	result = /datum/component/construction/mecha/medigax
	steps = list(
		/obj/item/mecha_parts/part/medigax_torso,
		/obj/item/mecha_parts/part/medigax_left_arm,
		/obj/item/mecha_parts/part/medigax_right_arm,
		/obj/item/mecha_parts/part/medigax_left_leg,
		/obj/item/mecha_parts/part/medigax_right_leg,
		/obj/item/mecha_parts/part/medigax_head
	)

/datum/component/construction/mecha/medigax
	result = /obj/vehicle/sealed/mecha/medical/medigax
	base_icon = "medigax"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//16
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//17
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//18
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//19
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//20
		list(
			"key" = /obj/item/mecha_parts/part/medigax_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),

	)

/datum/component/construction/mecha/medigax/action(datum/source, atom/used_atom, mob/user)
	return check_step(used_atom,user)

/datum/component/construction/mecha/medigax/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", span_notice("You secure the weapon control module."))
			else
				user.visible_message("[user] removes the weapon control module from [parent].", span_notice("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the weapon control module.", span_notice("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", span_notice("You secure the capacitor."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the capacitor.", span_notice("You unfasten the capacitor."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures Gygax Armor Plates.", span_notice("You secure Medical Gygax Armor Plates."))
			else
				user.visible_message("[user] pries Gygax Armor Plates from [parent].", span_notice("You pry Medical Gygax Armor Plates from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds Gygax Armor Plates to [parent].", span_notice("You weld Medical Gygax Armor Plates to [parent]."))
			else
				user.visible_message("[user] unfastens Gygax Armor Plates.", span_notice("You unfasten  Medical Gygax Armor Plates."))
	return TRUE
// End Medigax

/datum/component/construction/unordered/mecha_chassis/durand
	result = /datum/component/construction/mecha/durand
	steps = list(
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_head
	)

/datum/component/construction/mecha/durand
	result = /obj/vehicle/sealed/mecha/combat/durand
	base_icon = "durand"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/durand/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/durand/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/durand/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//16
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//17
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//18
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//19
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//20
		list(
			"key" = /obj/item/mecha_parts/part/durand_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)


/datum/component/construction/mecha/durand/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", span_notice("You secure the weapon control module."))
			else
				user.visible_message("[user] removes the weapon control module from [parent].", span_notice("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the weapon control module.", span_notice("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", span_notice("You secure the capacitor."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the capacitor.", span_notice("You unfasten the capacitor."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures Durand Armor Plates.", span_notice("You secure Durand Armor Plates."))
			else
				user.visible_message("[user] pries Durand Armor Plates from [parent].", span_notice("You pry Durand Armor Plates from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds Durand Armor Plates to [parent].", span_notice("You weld Durand Armor Plates to [parent]."))
			else
				user.visible_message("[user] unfastens Durand Armor Plates.", span_notice("You unfasten Durand Armor Plates."))
	return TRUE

//PHAZON

/datum/component/construction/unordered/mecha_chassis/phazon
	result = /datum/component/construction/mecha/phazon
	steps = list(
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg,
		/obj/item/mecha_parts/part/phazon_head
	)

/datum/component/construction/mecha/phazon
	result = /obj/vehicle/sealed/mecha/combat/phazon
	base_icon = "phazon"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/phazon/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/phazon/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed"
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/phazon/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stack/ore/bluespace_crystal,
			"amount" = 1,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//16
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The bluespace crystal is installed."
		),

		//17
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "The bluespace crystal is connected."
		),

		//18
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The bluespace crystal is engaged."
		),

		//19
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed.",
			"icon_state" = "phazon17"
			// This is the point where a step icon is skipped, so "icon_state" had to be set manually starting from here.
		),

		//20
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured.",
			"icon_state" = "phazon18"
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Phase armor is installed.",
			"icon_state" = "phazon19"
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Phase armor is wrenched.",
			"icon_state" = "phazon20"
		),

		//23
		list(
			"key" = /obj/item/mecha_parts/part/phazon_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Phase armor is welded.",
			"icon_state" = "phazon21"
		),

		//24
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed.",
			"icon_state" = "phazon22"
		),

		//25
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched.",
			"icon_state" = "phazon23"
		),

		//26
		list(
			"key" = /obj/item/assembly/signaler/anomaly,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Anomaly core socket is open.",
			"icon_state" = "phazon24"
		),
	)


/datum/component/construction/mecha/phazon/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", span_notice("You secure the weapon control module."))
			else
				user.visible_message("[user] removes the weapon control module from [parent].", span_notice("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the weapon control module.", span_notice("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures [I].", span_notice("You secure [I]."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I].", span_notice("You install [I]."))
			else
				user.visible_message("[user] unsecures the capacitor from [parent].", span_notice("You unsecure the capacitor from [parent]."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] connects the bluespace crystal.", span_notice("You connect the bluespace crystal."))
			else
				user.visible_message("[user] removes the bluespace crystal from [parent].", span_notice("You remove the bluespace crystal from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] engages the bluespace crystal.", span_notice("You engage the bluespace crystal."))
			else
				user.visible_message("[user] disconnects the bluespace crystal from [parent].", span_notice("You disconnect the bluespace crystal from [parent]."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disengages the bluespace crystal.", span_notice("You disengage the bluespace crystal."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs the phase armor layer to [parent].", span_notice("You install the phase armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phase armor layer.", span_notice("You secure the phase armor layer."))
			else
				user.visible_message("[user] pries the phase armor layer from [parent].", span_notice("You pry the phase armor layer from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds the phase armor layer to [parent].", span_notice("You weld the phase armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the phase armor layer.", span_notice("You unfasten the phase armor layer."))
		if(23)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] cuts phase armor layer from [parent].", span_notice("You cut the phase armor layer from [parent]."))
		if(24)
			if(diff==FORWARD)
				user.visible_message("[user] secures Phazon Armor Plates.", span_notice("You secure Phazon Armor Plates."))
			else
				user.visible_message("[user] pries Phazon Armor Plates from [parent].", span_notice("You pry Phazon Armor Plates from [parent]."))
		if(25)
			if(diff==FORWARD)
				user.visible_message("[user] welds Phazon Armor Plates to [parent].", span_notice("You weld Phazon Armor Plates to [parent]."))
			else
				user.visible_message("[user] unfastens Phazon Armor Plates.", span_notice("You unfasten Phazon Armor Plates."))
		if(26)
			if(diff==FORWARD)
				user.visible_message("[user] carefully inserts the anomaly core into [parent] and secures it.",
					span_notice("You slowly place the anomaly core into its socket and close its chamber."))
	return TRUE

//ODYSSEUS

/datum/component/construction/unordered/mecha_chassis/odysseus
	result = /datum/component/construction/mecha/odysseus
	steps = list(
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
	)

/datum/component/construction/mecha/odysseus
	result = /obj/vehicle/sealed/mecha/medical/odysseus
	base_icon = "odysseus"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/odysseus/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/odysseus/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),
		//9
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//11
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//12
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//13
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//14
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//15
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//16
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//17
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/component/construction/mecha/odysseus/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", span_notice("You secure the capacitor."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the capacitor.", span_notice("You unfasten the capacitor."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external armor layer to [parent].", span_notice("You install the external reinforced armor layer to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", span_notice("You secure the external reinforced armor layer."))
			else
				user.visible_message("[user] pries the external armor layer from [parent].", span_notice("You pry the external armor layer from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to [parent].", span_notice("You weld the external armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the external armor layer.", span_notice("You unfasten the external armor layer."))
	return TRUE

/datum/component/construction/unordered/mecha_chassis/ripley/clarke
	result = /datum/component/construction/mecha/ripley/clarke
	steps = list(
		/obj/item/mecha_parts/part/clarke_head,
		/obj/item/mecha_parts/part/clarke_torso,
		/obj/item/mecha_parts/part/clarke_left_arm,
		/obj/item/mecha_parts/part/clarke_right_arm,
		/obj/item/mecha_parts/part/clarke_left_tread,
		/obj/item/mecha_parts/part/clarke_right_tread
	)

/datum/component/construction/mecha/ripley/clarke
	result = /obj/vehicle/sealed/mecha/working/ripley/clarke
	base_icon = "clarke"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/clarke/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/clarke/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The scanner module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//15
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//16
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//17
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//18
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//19
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//20
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/component/construction/mecha/clarke/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures [I].", span_notice("You secure [I]."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I].", span_notice("You install [I]."))
			else
				user.visible_message("[user] unsecures the capacitor from [parent].", span_notice("You unsecure the capacitor from [parent]."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external reinforced armor layer to [parent].", span_notice("You install the external reinforced armor layer to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", span_notice("You secure the external reinforced armor layer."))
			else
				user.visible_message("[user] pries external armor layer from [parent].", span_notice("You pry external armor layer from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to [parent].", span_notice("You weld the external armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the external armor layer.", span_notice("You unfasten the external armor layer."))
	return TRUE

// MARAUDER

/datum/component/construction/unordered/mecha_chassis/marauder
	result = /datum/component/construction/mecha/marauder
	steps = list(
		/obj/item/mecha_parts/part/marauder_torso,
		/obj/item/mecha_parts/part/marauder_left_arm,
		/obj/item/mecha_parts/part/marauder_right_arm,
		/obj/item/mecha_parts/part/marauder_left_leg,
		/obj/item/mecha_parts/part/marauder_right_leg,
		/obj/item/mecha_parts/part/marauder_head
	)

/datum/component/construction/mecha/marauder
	result = /obj/vehicle/sealed/mecha/combat/marauder
	base_icon = "marauder"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/marauder/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/marauder/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/marauder/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),

		//16
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//17
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//18
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//19
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//20
		list(
			"key" = /obj/item/mecha_parts/part/marauder_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),

	)

/datum/component/construction/mecha/marauder/action(datum/source, atom/used_atom, mob/user)
	return check_step(used_atom,user)

/datum/component/construction/mecha/marauder/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [parent] hydraulic systems", span_notice("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [parent] hydraulic systems.", span_notice("You activate [parent] hydraulic systems."))
			else
				user.visible_message("[user] disconnects [parent] hydraulic systems", span_notice("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [parent].", span_notice("You add the wiring to [parent]."))
			else
				user.visible_message("[user] deactivates [parent] hydraulic systems.", span_notice("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [parent].", span_notice("You adjust the wiring of [parent]."))
			else
				user.visible_message("[user] removes the wiring from [parent].", span_notice("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] disconnects the wiring of [parent].", span_notice("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", span_notice("You secure the mainboard."))
			else
				user.visible_message("[user] removes the central control module from [parent].", span_notice("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the mainboard.", span_notice("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", span_notice("You secure the peripherals control module."))
			else
				user.visible_message("[user] removes the peripherals control module from [parent].", span_notice("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the peripherals control module.", span_notice("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", span_notice("You secure the weapon control module."))
			else
				user.visible_message("[user] removes the weapon control module from [parent].", span_notice("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the weapon control module.", span_notice("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", span_notice("You secure the scanner module."))
			else
				user.visible_message("[user] removes the scanner module from [parent].", span_notice("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] unfastens the scanner module.", span_notice("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", span_notice("You secure the capacitor."))
			else
				user.visible_message("[user] removes the capacitor from [parent].", span_notice("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] into [parent].", span_notice("You install [I] into [parent]."))
			else
				user.visible_message("[user] unfastens the capacitor.", span_notice("You unfasten the capacitor."))
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", span_notice("You secure the power cell."))
			else
				user.visible_message("[user] pries the power cell from [parent].", span_notice("You pry the power cell from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [parent].", span_notice("You install the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the power cell.", span_notice("You unfasten the power cell."))
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", span_notice("You secure the internal armor layer."))
			else
				user.visible_message("[user] pries internal armor layer from [parent].", span_notice("You pry internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [parent].", span_notice("You weld the internal armor layer to [parent]."))
			else
				user.visible_message("[user] unfastens the internal armor layer.", span_notice("You unfasten the internal armor layer."))
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I] to [parent].", span_notice("You install [I] to [parent]."))
			else
				user.visible_message("[user] cuts the internal armor layer from [parent].", span_notice("You cut the internal armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures Marauder Armor Plates.", span_notice("You secure Marauder Armor Plates."))
			else
				user.visible_message("[user] pries Marauder Armor Plates from [parent].", span_notice("You pry Marauder Armor Plates from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds Marauder Armor Plates to [parent].", span_notice("You weld Marauder Armor Plates to [parent]."))
			else
				user.visible_message("[user] unfastens Marauder Armor Plates.", span_notice("You unfasten Marauder Armor Plates."))
	return TRUE
