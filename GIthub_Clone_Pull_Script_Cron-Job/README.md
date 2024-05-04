# https://betterstack.com/community/guides/linux/cron-jobs-getting-started/

# Open Crontab -Every operating system user has their own crontab file which is located in the /var/spool/cron/crontabs/
crontab -e 

# This is every 6 mins
*/6 * * * * /home/devops_cloud/Cron-Demo/script.sh

# Recommended command to use when you wish to delete a crontab file, as it will ask you to confirm your choice like this
crontab -r -i   

# Echos the current contents of the crontab file to the console.
crontab -l

