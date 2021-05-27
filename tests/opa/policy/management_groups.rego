package main

import data.child_modules

########################
# Rules
########################

# # # Compare the management groups display name and fail if they are not equal.
violation[msg] {
	mgs_plan_display_name != mgs_change_display_name
	msg := sprintf("The planned values: %v are not equal to the changed values %v", [mgs_plan_display_name, mgs_change_display_name])
}

# # # Compare the management groups name and fail if they are not equal.
violation[msg] {
	mgs_plan_name != mgs_change_name
	msg := sprintf("The planned values: %v are not equal to the changed values %v", [mgs_plan_name, mgs_change_name])
}

########################
# Library
########################

# # # Get the display name from all management groups in planned_values.yml
mgs_plan_display_name[module_name] = mgs {
	module := child_modules[_]
	module_name := module.address
	mgs := [mg |
		module.resources[i].type == "azurerm_management_group"

		#module.resources[i].name == "level_1"
		mg := module.resources[i].values.display_name
	]
}

# # # Get the display name from all management groups in the opa.json
mgs_change_display_name[module_name] = mgs {
	module := input.resource_changes[_]
	module_name := module.module_address
	mgs := [mg |
		input.resource_changes[r].type == "azurerm_management_group"
		input.resource_changes[r].module_address == module.module_address
		mg := input.resource_changes[r].change.after.display_name
	]
}

# # # Get the name from all management groups in planned_values.yml
mgs_plan_name[module_name] = mgs {
	module := child_modules[_]
	module_name := module.address
	mgs := [mg |
		module.resources[i].type == "azurerm_management_group"
		mg := module.resources[i].values.name
	]
}

# # #Get the name from all management groups in the opa.json
mgs_change_name[module_name] = mgs {
	module := input.resource_changes[_]
	module_name := module.module_address
	mgs := [mg |
		input.resource_changes[r].type == "azurerm_management_group"
		input.resource_changes[r].module_address == module.module_address
		mg := input.resource_changes[r].change.after.name
	]
}

########################################################################
# # #  Warnings are used for troubleshooting, uncomment to use.
########################################################################
# # #  Return all the management groups under each root_id
# warn[msg] {
# 	id := array.slice(mgs_change_display_name[i], 0, 1)
# 	mg := array.slice(mgs_change_display_name[i], 1, 100)
# 	msg := sprintf("For root_id %v, these management groups will be created: %v", [id, mg])
# }