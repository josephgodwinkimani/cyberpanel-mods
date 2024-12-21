# cyberpanel-mods
Small changes to cyberpanel core installation

phpMyAdmin + Snappymail version changer. Enter php version without "."

# For php8.1 write choose "81" in the script.
```
sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/phpmod.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/phpmod.sh)
```
![](https://community.cyberpanel.net/uploads/default/original/2X/0/00feaa708386036ce807b7d7b67c57230f2dfe45.png)

______________________________

# Snappymail version changer
Input version you want to change to e.g 2.18.2
```
sh <(curl https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/snappymail_v_changer.sh || wget -O - https://raw.githubusercontent.com/tbaldur/cyberpanel-mods/main/snappymail_v_changer.sh)
```
![imagem](https://user-images.githubusercontent.com/97204751/192609788-355a24ec-e0cf-407a-91b7-51bb4121e5f4.png)


______________________________

# Fix missing acme-challenge context on all vhosts config
```
sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/fix_ssl_missing_context.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/fix_ssl_missing_context.sh)
```

![imagem](https://user-images.githubusercontent.com/97204751/186309709-30e11069-4833-4d05-b118-d7ba55960b56.png)

_____________________________
# Remove two-step authentification when you lost it
```
sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/disable_2fa.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/disable_2fa.sh)
```

![imagem](https://user-images.githubusercontent.com/97204751/186309709-30e11069-4833-4d05-b118-d7ba55960b56.png)

_____________________________
# Install cyberpanel core database in case you deleted it
```
sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/restore_cyberpanel_database.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/restore_cyberpanel_database.sh)
```

______________________________
# ALPHA FEATURES BELLOW! NEEDS PROPER TESTING! USE AT YOUR OWN RISK!
## Cyberpanel core permissions fix

Run in case you messed your cyberpanel permissions. 
```
sh <(curl https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/fix_permissions.sh || wget -O - https://raw.githubusercontent.com/josephgodwinkimani/cyberpanel-mods/main/fix_permissions.sh)
```
