#!/usr/bin/env bash

# print usage
DOMAIN=$1
if [ -z "$1" ]; then 

    echo "USAGE: $0 domain.lan"
    echo ""
    echo "This will generate a non-secure self-signed wildcard certificate for given domain."
    echo "This should only be used in a development environment."
    exit
fi

# Add wildcard
WILDCARD="*.$DOMAIN"

# Set our CSR variables
SUBJ="
C=BY
ST=Minsk
O=EDO
localityName=EDO
commonName=$WILDCARD
organizationalUnitName=EDO
emailAddress=EDOSmtpIba@gmail.com
"

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$DOMAIN.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$DOMAIN.key" -out "$DOMAIN.csr"
openssl x509 -req -days 3650 -in "$DOMAIN.csr" -signkey "$DOMAIN.key" -out "$DOMAIN.crt"
rm "$DOMAIN.csr"
