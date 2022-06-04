#!/bin/bash

function create_OrdererOrg() {
  infoln "Enrolling the CA admin"
  mkdir -p config/crypto-config/ordererOrganizations/edu.tw

  export FABRIC_CA_CLIENT_HOME=${PWD}/config/crypto-config/ordererOrganizations/edu.tw

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/config/ca-config/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/config/crypto-config/ordererOrganizations/edu.tw/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/config/ca-config/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/config/ca-config/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp --csr.hosts orderer0.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/msp/config.yaml ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls --enrollment.profile tls --csr.hosts orderer0.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/config/ca-config/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/ca.crt
  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/signcerts/* ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/server.crt
  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/keystore/* ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/server.key

  mkdir -p ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/tlscacerts/tlsca.edu.tw-cert.pem

  mkdir -p ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/msp/tlscacerts
  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/tlscacerts/* ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/msp/tlscacerts/tlsca.edu.tw-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/users/Admin@edu.tw/msp --tls.certfiles ${PWD}/config/ca-config/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/msp/config.yaml ${PWD}/config/crypto-config/ordererOrganizations/edu.tw/users/Admin@edu.tw/msp/config.yaml
}
