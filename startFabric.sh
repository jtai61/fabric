#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
MAX_RETRY=5
# default for delay between commands
CLI_DELAY=3
# channel name
CHANNEL_NAME="channel"
# chaincode name defaults to "NA"
CC_NAME="chaincode"
# chaincode path
CC_SRC_PATH="chaincode/"
# endorsement policy defaults to "NA". This would allow chaincodes to use the majority default policy.
CC_END_POLICY="NA"
# collection configuration defaults to "NA"
CC_COLL_CONFIG="NA"
# chaincode init function defaults to "NA"
CC_INIT_FCN="NA"
# chaincode language
CC_SRC_LANGUAGE="javascript"
# Chaincode version
CC_VERSION="1.0"
# Chaincode definition sequence
CC_SEQUENCE=1

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config
export VERBOSE=false

. scripts/utils.sh

# Create Organization crypto material
function createOrgCrypto() {

  infoln "Generating certificates using Fabric CA"

  docker compose -f docker/${ORGANIZATION_NAME}/docker-compose-ca.yaml up -d

  . organizations/${ORGANIZATION_NAME}/registerEnroll.sh

  if [ $ORGANIZATION_NAME != "orderer" ]; then
  
    if [ $ORGANIZATION_NAME == "tn" ]; then
      infoln "Creating TnOrg Identities"
      create_TnOrg
    elif [ $ORGANIZATION_NAME == "tc" ]; then
      infoln "Creating TcOrg Identities"
      create_TcOrg
    fi

    infoln "Generating CCP files"
    . organizations/${ORGANIZATION_NAME}/ccp-generate.sh

  else
    infoln "Creating OrdererOrg Identities"
    create_OrdererOrg

  fi
}

# Generate orderer system channel genesis block.
function createGenesisBlock() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    fatalln "configtxgen tool not found."
  fi

  infoln "Generating Orderer Genesis block"

  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./config/network-config/genesis.block
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    fatalln "Failed to generate orderer genesis block..."
  fi
}

# Bring up the peer using docker compose
function networkUp() {

  if [ $ORGANIZATION_NAME != "orderer" ]; then
    docker compose -f docker/${ORGANIZATION_NAME}/docker-compose-base.yaml -f docker/${ORGANIZATION_NAME}/docker-compose-couch.yaml up -d
  else
    docker compose -f docker/${ORGANIZATION_NAME}/docker-compose-base.yaml up -d
  fi

  docker container ls --all
}

# call the script to create the channel, join the peers of org1 and org2,
# and then update the anchor peers for each organization
function createChannel() {
  # Bring up the network if it is not already up.

  if [ ! -d "organizations/peerOrganizations" ]; then
    infoln "Bringing up network"
    networkUp
  fi

  # now run the script that creates a channel. This script uses configtxgen once
  # more to create the channel creation transaction and the anchor peer updates.
  # configtx.yaml is mounted in the cli container, which allows us to use it to
  # create the channel artifacts
  scripts/createChannel.sh $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE
}

# Call the script to deploy a chaincode to the channel
function deployCC() {
  scripts/deployCC.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE

  if [ $? -ne 0 ]; then
    fatalln "Deploying chaincode failed"
  fi
}


# parse flags
while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -org )
    ORGANIZATION_NAME="$2"
    shift
    ;;
  -c )
    CHANNEL_NAME="$2"
    shift
    ;;
  -ca )
    CRYPTO="Certificate Authorities"
    ;;
  -r )
    MAX_RETRY="$2"
    shift
    ;;
  -d )
    CLI_DELAY="$2"
    shift
    ;;
  -s )
    DATABASE="$2"
    shift
    ;;
  -ccl )
    CC_SRC_LANGUAGE="$2"
    shift
    ;;
  -ccn )
    CC_NAME="$2"
    shift
    ;;
  -ccv )
    CC_VERSION="$2"
    shift
    ;;
  -ccs )
    CC_SEQUENCE="$2"
    shift
    ;;
  -ccp )
    CC_SRC_PATH="$2"
    shift
    ;;
  -ccep )
    CC_END_POLICY="$2"
    shift
    ;;
  -cccg )
    CC_COLL_CONFIG="$2"
    shift
    ;;
  -cci )
    CC_INIT_FCN="$2"
    shift
    ;;
  -i )
    IMAGETAG="$2"
    shift
    ;;
  -cai )
    CA_IMAGETAG="$2"
    shift
    ;;
  -verbose )
    VERBOSE=true
    shift
    ;;
  * )
    errorln "Unknown flag: $key"
    printHelp
    exit 1
    ;;
  esac
  shift
done


networkUp


# # run fabric api server
# pushd ./apiserver
# npm install
# node enrollAdmin.js
# node registerUser.js
# node index.js
# popd