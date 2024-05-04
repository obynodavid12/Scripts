#!/bin/bash

# Delete the .vscode-server directory every day at 4am

# Set the crontab entry
(crontab -l 2>/dev/null; echo "0 4 * * * rm -rf ~/.vscode-server") | crontab -

# Print a message to the user
echo "The .vscode-server directory will now be deleted every day at 4am."