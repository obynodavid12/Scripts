#!/bin/bash

# List Policies attached to Users and Prints PolicyNames/Groups
aws iam list-users | grep -i username > list_users ; cat list_users |awk '{print $NF}' |tr '\"' ' ' |tr '\,' ' '|while read user; do echo "\n\n--------------Getting information for user $user-----------\n\n" ; aws iam list-user-policies --user-name $user --output yaml; aws iam list-groups-for-user  --user-name $user --output yaml;aws iam  list-attached-user-policies --user-name $user --output yaml ;done ;echo;echo