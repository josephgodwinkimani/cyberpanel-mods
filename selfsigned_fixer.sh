#!/bin/bash

#Ask for domain
echo "Which domain do you want to issue SSL certificate? (e.g mydomain.com) "
read DOMAIN

if [[ ! -d /etc/letsencrypt/live ]]; then
    echo "Please run upgrade script - https://community.cyberpanel.net/docs?topic=81"
    exit
fi

echo "Remove only the domain keys NOT mail or any other subdomains for the same domain"
rm -f /etc/letsencrypt/live/$DOMAIN/privkey.pem && rm -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem
echo "Issuing SSL certificate with Let's Encrypt"
/root/.acme.sh/acme.sh --issue -d $DOMAIN -d www.$DOMAIN --cert-file /etc/letsencrypt/live/$DOMAIN/cert.pem --key-file /etc/letsencrypt/live/$DOMAIN/privkey.pem --fullchain-file /etc/letsencrypt/live/$DOMAIN/fullchain.pem -w /usr/local/lsws/Example/html --force --debug
