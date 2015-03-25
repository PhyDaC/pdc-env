#!/bin/bash
#
set -e -x -o nounset


# Add admin account
#
mongo query_composer_development --port 27019 --eval 'db.users.insert({
	"first_name" : "PDC",
	"last_name" : "Admin",
	"username" : "pdcadmin",
	"email" : "pdcadmin@pdc.io",
	"encrypted_password" : "$2a$10$ZSuPxdODbumiMGOxtVSpRu0Rd0fQ2HhC7tMu2IobKTaAsPMmFlBD.",
	"agree_license" : true,
	"approved" : true,
	"admin" : true
})'
