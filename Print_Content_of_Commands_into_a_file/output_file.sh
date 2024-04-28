#!/bin/bash

# Run multiple commands
echo "This is the first command output."
ls -l
date

# Redirect the output to a file
output_file="output.txt"
echo "Command output saved to $output_file"
> $output_file
echo "This is the first command output." >> $output_file
ls -l >> $output_file
date >> $output_file

