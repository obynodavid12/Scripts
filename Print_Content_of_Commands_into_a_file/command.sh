#!/bin/bash

get_system_info() {
    echo "------ Output into check.txt ------"
	whoami
    echo "------ Output into check.txt ------"
    hostname
    echo "------ Output into check.txt ------"
	date
}

echo "output into check.txt"
get_system_info > check.txt

# ( whoami; hostname; date; ) >check.txt

# { whoami; hostname; date; } >check.txt

