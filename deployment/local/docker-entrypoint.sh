#!/bin/bash
set -Ee
echo "----------------------------- ENTRYPOINT (LOCAL) ---------------------------------"
cd /var/www/app
ls -la

#echo "---------------------------- SSL generate (LOCAL) --------------------------------"
FILE=/var/www/app/deployment/local/ssl/public.crt
if [ -f "$FILE" ]; then
    echo "$FILE exists. It's OK."
else
    cd /var/www/app/deployment/local/ssl

    openssl req -x509 -out public.crt -keyout private.key \
        -newkey rsa:2048 -nodes -sha256 \
        -subj '/CN=shop.loc' -extensions EXT -config <(echo -e "[dn]\nCN=shop.loc\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:shop.loc\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

    echo "SSL was generate success."
fi

#composer install
#php bin/console doctrine:migrations:migrate -n

#chmod -R 777 /var/www/app/var
exec "$@"
