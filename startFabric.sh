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
CC_NAME="NA"
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


# clean out any old identites in the wallets
# rm -rf apiserver/wallet/*

# pull fabric docker image
# ./requirements.sh

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config
export VERBOSE=false

. scripts/utils.sh

# Create Organization crypto material
function createOrgCrypto() {

  infoln "Generating certificates using Fabric CA"

  if [ $ORGANIZATION_NAME == "tn" ]; then

    docker-compose -f docker/tn/docker-compose-ca.yaml up -d

    . organizations/tn/registerEnroll.sh

    while :
    do
      if [ ! -f "config/ca-config/tn/tls-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done

    infoln "Creating TnOrg Identities"
    create_TnOrg

    infoln "Generating CCP files for TnOrg"
    . organizations/tn/ccp-generate.sh

  elif [ $ORGANIZATION_NAME == "tc" ]; then

    docker-compose -f docker/tc/docker-compose-ca.yaml up -d

    . organizations/tc/registerEnroll.sh

    while :
    do
      if [ ! -f "config/ca-config/tc/tls-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done

    infoln "Creating TcOrg Identities"
    create_TcOrg

    infoln "Generating CCP files for TcOrg"
    . organizations/tc/ccp-generate.sh

  elif [ $ORGANIZATION_NAME == "orderer" ]; then

    docker-compose -f docker/orderer/docker-compose-ca.yaml up -d

    . organizations/orderer/registerEnroll.sh

    while :
    do
      if [ ! -f "config/ca-config/orderer/tls-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done

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
  
  createOrgCrypto

  if [ $ORGANIZATION_NAME == "orderer" ]; then

    infoln "Copy crypto file to orderer org"
    sudo scp -r cils@192.168.1.10:/home/cils/fabricPRJ/config/ .
    sudo scp -r cils@192.168.1.20:/home/cils/fabricPRJ/config/ .
    
    createGenesisBlock

    infoln "Copy genesis.block file to TnOrg and TcOrg"
    sudo scp config/network-config/genesis.block cils@192.168.1.10:/home/cils/fabricPRJ/config/network-config/genesis.block
    sudo scp config/network-config/genesis.block cils@192.168.1.20:/home/cils/fabricPRJ/config/network-config/genesis.block
    
  fi

  if [ $ORGANIZATION_NAME == "tn" ]; then

    docker-compose -f docker/tn/docker-compose-base.yaml -f docker/tn/docker-compose-couch.yaml up -d

  elif [ $ORGANIZATION_NAME == "tc" ]; then

    docker-compose -f docker/tc/docker-compose-base.yaml -f docker/tc/docker-compose-couch.yaml up -d

  elif [ $ORGANIZATION_NAME == "orderer" ]; then

    docker-compose -f docker/orderer/docker-compose-base.yaml up -d

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



# # launch network; create channel and join peer to channel
# pushd ./bidding-network
# ./network.sh down
# ./network.sh up createChannel -ca -s couchdb
# ./network.sh deployCC -ccn bidding -ccv 1 -cci initLedger -ccl ${CC_SRC_LANGUAGE} -ccp ${CC_SRC_PATH}
# popd

# # run fabric api server
# pushd ./apiserver
# npm install
# node enrollAdmin.js
# node registerUser.js
# node index.js
# popd