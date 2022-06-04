#!/bin/bash

function create_TcOrg() {
  infoln "Enrolling the CA admin"
  mkdir -p config/crypto-config/peerOrganizations/tc.edu.tw/

  export FABRIC_CA_CLIENT_HOME=${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-tc --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-tc.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-tc.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-tc.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-tc.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/config.yaml

  infoln "Registering TcOrg's endorser"
  set -x
  fabric-ca-client register --caname ca-tc --id.name endorser --id.secret endorserpw --id.type peer --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's peer0"
  set -x
  fabric-ca-client register --caname ca-tc --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's peer1"
  set -x
  fabric-ca-client register --caname ca-tc --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's user"
  set -x
  fabric-ca-client register --caname ca-tc --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's admin"
  set -x
  fabric-ca-client register --caname ca-tc --id.name tcadmin --id.secret tcadminpw --id.type admin --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating TcOrg's endorser msp"
  set -x
  fabric-ca-client enroll -u https://endorser:endorserpw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/msp --csr.hosts endorser.tc.edu.tw --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/msp --csr.hosts peer0.tc.edu.tw --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/msp --csr.hosts peer1.tc.edu.tw --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's endorser-tls certificates"
  set -x
  fabric-ca-client enroll -u https://endorser:endorserpw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls --enrollment.profile tls --csr.hosts endorser.tc.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/tlsca
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/ca
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/endorser.tc.edu.tw/msp/cacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

  infoln "Generating TcOrg's peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls --enrollment.profile tls --csr.hosts peer0.tc.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/tlsca
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/ca
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/msp/cacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

  infoln "Generating TcOrg's peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls --enrollment.profile tls --csr.hosts peer1.tc.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/tlsca
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/ca
  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/msp/cacerts/* ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

  infoln "Generating TcOrg's user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/users/User1@tc.edu.tw/msp --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/users/User1@tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's admin msp"
  set -x
  fabric-ca-client enroll -u https://tcadmin:tcadminpw@localhost:8054 --caname ca-tc -M ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/users/Admin@tc.edu.tw/msp --tls.certfiles ${PWD}/config/ca-config/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/config/crypto-config/peerOrganizations/tc.edu.tw/users/Admin@tc.edu.tw/msp/config.yaml
}
