#!/usr/bin/env bash

# These certs file is only for Harbor testing.
CN='127.0.0.1'

IPV4_REGEX='((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])'
IPV6_REGEX='(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
TEMP_FILENAME='temp'
if [ ! -z "$1" ]; then CN=$1; fi
OPENSSLCNF=
DATA_VOL='/data'
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for path in /etc/openssl/openssl.cnf /etc/ssl/openssl.cnf /usr/local/etc/openssl/openssl.cnf; do
    if [[ -e ${path} ]]; then
        OPENSSLCNF=${path}
    fi
done
if [[ -z ${OPENSSLCNF} ]]; then
    printf "Could not find openssl.cnf"
    exit 1
fi

# Create CA certificate
# openssl req \
#    -newkey rsa:4096 -nodes -sha256 -keyout $CUR_DIR/harbor_ca.key \
#    -x509 -days 365 -out $CUR_DIR/harbor_ca.crt -subj '/C=CN/ST=PEK/L=Bei Jing/O=VMware/CN=HarborCA'

# Generate a Certificate Signing Request
if [[ $CN =~ $IPV4_REGEX ]] || [[ $CN =~ $IPV6_REGEX ]] ; then
openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout $TEMP_FILENAME.key \
    -out $TEMP_FILENAME.csr -subj "/C=CN/ST=PEK/L=Bei Jing/O=VMware/CN=HarborManager"
echo subjectAltName = IP:$CN > extfile.cnf
else
openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout $TEMP_FILENAME.key \
    -out $TEMP_FILENAME.csr -subj "/C=CN/ST=PEK/L=Bei Jing/O=VMware/CN=$CN"
echo subjectAltName = DNS.1:$CN > extfile.cnf
fi

# Generate the certificate of local registry host
openssl x509 -req -days 365 -sha256 -in $TEMP_FILENAME.csr -CA $CUR_DIR/harbor_ca.crt \
	-CAkey $CUR_DIR/harbor_ca.key -CAcreateserial -extfile extfile.cnf -out $TEMP_FILENAME.crt
	
# Copy to harbor default location
mkdir -p $DATA_VOL/cert
cp $TEMP_FILENAME.crt $DATA_VOL/cert/server.crt
cp $TEMP_FILENAME.key $DATA_VOL/cert/server.key
