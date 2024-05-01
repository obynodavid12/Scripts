#!/bin/bash
# employee=$(curl -s http://dummy.restapiexample.com/api/v1/employees | jq -r .data[0].employee_name)
# #echo "Hello $employee" | cut -d ' ' -f 1,3
# echo "Hello $employee" | awk -F " " '{ print $3; }'

# whoami ; hostname

# Define the output file
output_file="output.txt"

# Run the commands sequentially and append the output to the file
echo "Command 1 output" > $output_file
date +%B >> $output_file
date >> $output_file
date +"%T" >> $output_file
date +%B    >> $output_file
date +%d    >> $output_file
date +%D   >> $output_file

echo "Command 2 output" >> $output_file
pwd >> $output_file
whoami >> $output_file
hostname >> $output_file


echo "Command 3 output" >> $output_file
df -h >> $output_file
echo $SHELL >> $output_file
date +"%m%d%H%M%Y.%S" >> $output_file


