#!/usr/bin/env python
import subprocess
with open("output.txt", "w+") as output:
    subprocess.call(["sh", "./script.sh"], stdout=output);

# This code prints the output of the script.sh file to the output.txt file.