# Scripts
<!-- https://linuxconfig.org/bash-scripting-tutorial
https://tldp.org/LDP/Bash-Beginners-Guide/html/ -->

# JUST SIMPLE RUN THIS COMMAND WHILE EXECUTING THE script.sh
./script.sh > file.txt

# FOR MULTIPLE COMMANDS IN LINUX
1. A; B    # Run A and then B, regardless of success of A
2. A && B  # Run B if and only if A succeeded
3. A || B  # Run B if and only if A failed
4. A &     # Run A in background.
5. A & B  # runs simultaneously

Use ().
If you want to run them sequentially:
1. (myCommand1; myCommand2) &
or
2. (myCommand1 &) && (myCommand2 &)
If you want them to run parallel:
3. myCommand1 & myCommand2 &
In bash you can also use this (space behind the { and the ; are mandatory):
4. { myCommand1 && myCommand2; } &
