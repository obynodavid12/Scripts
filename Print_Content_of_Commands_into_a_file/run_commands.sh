#!/bin/bash

# Run multiple commands
whoami;
hostname;
ls -l;
date

# Redirect the output to file.txt
whoami > file.txt
hostname >> file.txt
ls -l >> file.txt
date >> file.txt