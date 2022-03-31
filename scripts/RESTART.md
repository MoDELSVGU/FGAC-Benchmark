https://askubuntu.com/questions/155791/how-do-i-sudo-a-command-in-a-script-without-being-asked-for-a-password

sudo chown root:root ./restartmysql.sh
sudo chmod 700 ./restartmysql.sh

sudo visudo
<!-- Line 25 -->
%sudo   ALL=(ALL:ALL) ALL 
username  ALL=(ALL) NOPASSWD: <!-- path -->/restartmysql