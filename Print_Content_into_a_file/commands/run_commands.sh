#!/bin/bash

# Run multiple commands
whoami > file.txt; echo '--------- name';sleep 1;
hostname >> file.txt; echo '--------- hostname';sleep 1;
ls -l >> file.txt; echo '--------- listing files';sleep 1;
date >> file.txt; echo '--------- show date';sleep 1;

# # Redirect the output to file.txt
# whoami > file.txt
# hostname >> file.txt
# ls -l >> file.txt
# date >> file.txt