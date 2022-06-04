#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGI}/$6/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/tc/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${ORGI}/$6/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/tc/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG="Tc"
ORGI="tc"
P0PORT=9051
CAPORT=8054
PEERPEM=config/crypto-config/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem
CAPEM=config/crypto-config/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGI)" > config/crypto-config/peerOrganizations/tc.edu.tw/connection-tc.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGI)" > config/crypto-config/peerOrganizations/tc.edu.tw/connection-tc.yaml
