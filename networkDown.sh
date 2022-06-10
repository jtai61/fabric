#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -ex

# Obtain CONTAINER_IDS and remove them
# TODO Might want to make this optional - could clear other containers
# This function is called when you bring a network down
function clearContainers() {
  CONTAINER_IDS=$(docker container ls -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    infoln "No containers available for deletion"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# This function is called when you bring the network down
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    infoln "No images available for deletion"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

# Tear down running network
function networkDown() {

  if [ $ORGANIZATION_NAME != "orderer" ]; then
    # stop all containers
    # Bring down the network, deleting the volumes
    docker compose -f docker/${ORGANIZATION_NAME}/docker-compose-base.yaml -f docker/${ORGANIZATION_NAME}/docker-compose-couch.yaml -f docker/${ORGANIZATION_NAME}/docker-compose-ca.yaml down --volumes --remove-orphans
  else
    docker compose -f docker/${ORGANIZATION_NAME}/docker-compose-base.yaml -f docker/${ORGANIZATION_NAME}/docker-compose-ca.yaml down --volumes --remove-orphans  
  fi

  # Cleanup the chaincode containers
  clearContainers
  # Cleanup images
  removeUnwantedImages
  # Cleanup apiserver folder
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data && rm -rf organizations/${ORGANIZATION_NAME}/apiserver/wallet/* organizations/${ORGANIZATION_NAME}/apiserver/node_modules"
  # remove orderer block and other channel configuration transactions and certs
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data && rm -rf config/network-config/*"
  # remove ca-config file
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data/config/ca-config/tn && find . ! -name fabric-ca-server-config.yaml -delete"
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data/config/ca-config/tc && find . ! -name fabric-ca-server-config.yaml -delete"
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data/config/ca-config/orderer && find . ! -name fabric-ca-server-config.yaml -delete"
  # remove crypto-config file
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data && rm -rf config/cypto-config/ordererOrganizations/* config/cypto-config/peerOrganizations/*"
  # remove channel and script artifacts
  docker container run --rm -v $(pwd):/data busybox sh -c "cd /data && rm -rf log.txt *.tar.gz"

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


networkDown
