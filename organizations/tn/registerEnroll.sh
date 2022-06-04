#!/bin/bash

function create_TnOrg() {
  infoln "Enrolling the CA admin"
  mkdir -p config/crypto-config/peerOrganizations/tn.edu.tw/

  export FABRIC_CA_CLIENT_HOME=${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-tn --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-tn.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-tn.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-tn.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-tn.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/config.yaml

  infoln "Registering TnOrg's endorser"
  set -x
  fabric-ca-client register --caname ca-tn --id.name endorser --id.secret endorserpw --id.type peer --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's peer0"
  set -x
  fabric-ca-client register --caname ca-tn --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's peer1"
  set -x
  fabric-ca-client register --caname ca-tn --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's user"
  set -x
  fabric-ca-client register --caname ca-tn --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's admin"
  set -x
  fabric-ca-client register --caname ca-tn --id.name tnadmin --id.secret tnadminpw --id.type admin --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating TnOrg's endorser msp"
  set -x
  fabric-ca-client enroll -u https://endorser:endorserpw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/msp --csr.hosts endorser.tn.edu.tw --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/msp --csr.hosts peer0.tn.edu.tw --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/msp --csr.hosts peer1.tn.edu.tw --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's endorser-tls certificates"
  set -x
  fabric-ca-client enroll -u https://endorser:endorserpw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls --enrollment.profile tls --csr.hosts endorser.tn.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/tlsca
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/ca
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/endorser.tn.edu.tw/msp/cacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

  infoln "Generating TnOrg's peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls --enrollment.profile tls --csr.hosts peer0.tn.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/tlsca
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/ca
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/msp/cacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

  infoln "Generating TnOrg's peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls --enrollment.profile tls --csr.hosts peer1.tn.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/tlsca
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/ca
  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/msp/cacerts/* ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

  infoln "Generating TnOrg's user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/users/User1@tn.edu.tw/msp --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/users/User1@tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's admin msp"
  set -x
  fabric-ca-client enroll -u https://tnadmin:tnadminpw@localhost:7054 --caname ca-tn -M ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/users/Admin@tn.edu.tw/msp --tls.certfiles ${PWD}/config/ca-config/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tn.edu.tw/users/Admin@tn.edu.tw/msp/config.yaml
}
