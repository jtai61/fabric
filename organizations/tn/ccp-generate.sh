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
        organizations/tn/ccp-template.json
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
        organizations/tn/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG="Tn"
ORGI="tn"
P0PORT=7051
CAPORT=7054
PEERPEM=config/crypto-config/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem
CAPEM=config/crypto-config/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGI)" > organizations/tn/connection-tn.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORGI)" > organizations/tn/connection-tn.yaml
