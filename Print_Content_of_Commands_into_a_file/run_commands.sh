#!/bin/bash

# Run multiple commands
whoami; echo '---------';sleep 1;
hostname; echo '---------';sleep 1;
ls -l; echo '---------';sleep 1;
date; echo '---------';sleep 1;

# Redirect the output to file.txt
whoami > file.txt
hostname >> file.txt
ls -l >> file.txt
date >> file.txt