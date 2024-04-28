# Scripts
<!-- https://linuxconfig.org/bash-scripting-tutorial
https://tldp.org/LDP/Bash-Beginners-Guide/html/ -->

# JUST SIMPLE RUN THIS COMMAND WHILE EXECUTING THE script.sh
./script.sh > file.txt

# FOR MULTIPLE COMMANDS IN LINUX
A; B    # Run A and then B, regardless of success of A
A && B  # Run B if and only if A succeeded
A || B  # Run B if and only if A failed
A &     # Run A in background.
A & B  # runs simultaneously

Use ().
If you want to run them sequentially:
(myCommand1; myCommand2) &
or
(myCommand1 &) && (myCommand2 &)

If you want them to run parallel:
myCommand1 & myCommand2 &

In bash you can also use this (space behind the { and the ; are mandatory):
{ myCommand1 && myCommand2; } &
