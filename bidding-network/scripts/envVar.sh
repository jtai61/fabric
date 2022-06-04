#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/edu.tw/orderers/orderer0.edu.tw/msp/tlscacerts/tlsca.edu.tw-cert.pem
export ANCHORPEER_TN_CA=${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/anchorpeer.tn.edu.tw/tls/ca.crt
export PEER0_TN_CA=${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer0.tn.edu.tw/tls/ca.crt
export PEER1_TN_CA=${PWD}/organizations/peerOrganizations/tn.edu.tw/peers/peer1.tn.edu.tw/tls/ca.crt
export ANCHORPEER_TC_CA=${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/anchorpeer.tc.edu.tw/tls/ca.crt
export PEER0_TC_CA=${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer0.tc.edu.tw/tls/ca.crt
export PEER1_TC_CA=${PWD}/organizations/peerOrganizations/tc.edu.tw/peers/peer1.tc.edu.tw/tls/ca.crt

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG == "tn" ]; then
    export CORE_PEER_LOCALMSPID="TnMSP"
    if [ $2 == "anchorpeer" ]; then
      export CORE_PEER_TLS_ROOTCERT_FILE=$ANCHORPEER_TN_CA
      export CORE_PEER_ADDRESS=localhost:7051
    elif [ $2 == "peer0" ]; then
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_TN_CA
      export CORE_PEER_ADDRESS=localhost:1051
    elif [ $2 == "peer1" ]; then
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_TN_CA
      export CORE_PEER_ADDRESS=localhost:2051
    fi
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/tn.edu.tw/users/Admin@tn.edu.tw/msp
  elif [ $USING_ORG == "tc" ]; then
    export CORE_PEER_LOCALMSPID="TcMSP"
    if [ $2 == "anchorpeer" ]; then
      export CORE_PEER_TLS_ROOTCERT_FILE=$ANCHORPEER_TC_CA
      export CORE_PEER_ADDRESS=localhost:9051
    elif [ $2 == "peer0" ]; then
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_TC_CA
      export CORE_PEER_ADDRESS=localhost:3051
    elif [ $2 == "peer1" ]; then
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_TC_CA
      export CORE_PEER_ADDRESS=localhost:4051
    fi
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/tc.edu.tw/users/Admin@tc.edu.tw/msp
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1 "anchorpeer"
    PEER="anchorpeer.$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$ANCHORPEER_${1^^}_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
