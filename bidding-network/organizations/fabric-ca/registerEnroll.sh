#!/bin/bash

function create_TnOrg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/tn.edu.tw/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/tn.edu.tw/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-tn --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
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
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/config.yaml

  infoln "Registering TnOrg's anchorpeer"
  set -x
  fabric-ca-client register --caname ca-tn --id.name anchorpeer --id.secret anchorpeerpw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's peer0"
  set -x
  fabric-ca-client register --caname ca-tn --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's peer1"
  set -x
  fabric-ca-client register --caname ca-tn --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's user"
  set -x
  fabric-ca-client register --caname ca-tn --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TnOrg's admin"
  set -x
  fabric-ca-client register --caname ca-tn --id.name tnadmin --id.secret tnadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating TnOrg's anchorpeer msp"
  set -x
  fabric-ca-client enroll -u https://anchorpeer:anchorpeerpw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/msp --csr.hosts anchorpeer.tn.edu.tw --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/msp --csr.hosts peer0.tn.edu.tw --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/msp --csr.hosts peer1.tn.edu.tw --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's anchorpeer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://anchorpeer:anchorpeerpw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls --enrollment.profile tls --csr.hosts anchorpeer.tn.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/signcerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/keystore/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/tlsca
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/ca
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/msp/cacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

  infoln "Generating TnOrg's peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls --enrollment.profile tls --csr.hosts peer0.tn.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/signcerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/keystore/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/tlsca
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/ca
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/msp/cacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

  infoln "Generating TnOrg's peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls --enrollment.profile tls --csr.hosts peer1.tn.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/signcerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/keystore/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/tlsca
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/tlsca/tlsca.tn.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/tn.edu.tw/ca
  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/msp/cacerts/* ${PWD}/organizations/peerOrganizations/tn.edu.tw/ca/ca.tn.edu.tw-cert.pem

  infoln "Generating TnOrg's user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/users/User1@tn.edu.tw/msp --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tn.edu.tw/users/User1@tn.edu.tw/msp/config.yaml

  infoln "Generating TnOrg's admin msp"
  set -x
  fabric-ca-client enroll -u https://tnadmin:tnadminpw@localhost:7054 --caname ca-tn -M ${PWD}/organizations/peerOrganizations/tn.edu.tw/users/Admin@tn.edu.tw/msp --tls.certfiles ${PWD}/organizations/fabric-ca/tn/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tn.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tn.edu.tw/users/Admin@tn.edu.tw/msp/config.yaml
}

function create_TcOrg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/tc.edu.tw/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/tc.edu.tw/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-tc --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
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
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/config.yaml

  infoln "Registering TcOrg's anchorpeer"
  set -x
  fabric-ca-client register --caname ca-tc --id.name anchorpeer --id.secret anchorpeerpw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's peer0"
  set -x
  fabric-ca-client register --caname ca-tc --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's peer1"
  set -x
  fabric-ca-client register --caname ca-tc --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's user"
  set -x
  fabric-ca-client register --caname ca-tc --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering TcOrg's admin"
  set -x
  fabric-ca-client register --caname ca-tc --id.name tcadmin --id.secret tcadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating TcOrg's anchorpeer msp"
  set -x
  fabric-ca-client enroll -u https://anchorpeer:anchorpeerpw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/msp --csr.hosts anchorpeer.tc.edu.tw --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/msp --csr.hosts peer0.tc.edu.tw --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/msp --csr.hosts peer1.tc.edu.tw --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's anchorpeer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://anchorpeer:anchorpeerpw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls --enrollment.profile tls --csr.hosts anchorpeer.tc.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/signcerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/keystore/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/tlsca
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/ca
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/msp/cacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

  infoln "Generating TcOrg's peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls --enrollment.profile tls --csr.hosts peer0.tc.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/signcerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/keystore/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/tlsca
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/ca
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/msp/cacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

  infoln "Generating TcOrg's peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls --enrollment.profile tls --csr.hosts peer1.tc.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/signcerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/keystore/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/tlsca
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/tlsca/tlsca.tc.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/tc.edu.tw/ca
  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/msp/cacerts/* ${PWD}/organizations/peerOrganizations/tc.edu.tw/ca/ca.tc.edu.tw-cert.pem

  infoln "Generating TcOrg's user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/users/User1@tc.edu.tw/msp --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tc.edu.tw/users/User1@tc.edu.tw/msp/config.yaml

  infoln "Generating TcOrg's admin msp"
  set -x
  fabric-ca-client enroll -u https://tcadmin:tcadminpw@localhost:8054 --caname ca-tc -M ${PWD}/organizations/peerOrganizations/tc.edu.tw/users/Admin@tc.edu.tw/msp --tls.certfiles ${PWD}/organizations/fabric-ca/tc/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/tc.edu.tw/msp/config.yaml ${PWD}/organizations/peerOrganizations/tc.edu.tw/users/Admin@tc.edu.tw/msp/config.yaml
}

function create_OrdererOrg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/edu.tw

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/edu.tw

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
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
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/edu.tw/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp --csr.hosts orderer0.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/edu.tw/msp/config.yaml ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls --enrollment.profile tls --csr.hosts orderer0.edu.tw --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/keystore/* ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/tlscacerts/tlsca.edu.tw-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/edu.tw/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/edu.tw/msp/tlscacerts/tlsca.edu.tw-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/edu.tw/users/Admin@edu.tw/msp --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/edu.tw/msp/config.yaml ${PWD}/organizations/ordererOrganizations/edu.tw/users/Admin@edu.tw/msp/config.yaml
}
