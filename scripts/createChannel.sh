#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"

createChannelTx() {
	set -x
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./config/network-config/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannel() {
	setGlobals "tn" "endorser"
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel create -o orderer0.edu.tw:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer0.edu.tw -f ./config/network-config/${CHANNEL_NAME}.tx --outputBlock $BLOCKFILE --tls --cafile $ORDERER_CA >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

# joinChannel ORG
joinChannel() {
  # FABRIC_CFG_PATH=$PWD/../config/
  ORG=$1
	PEER=$2
  setGlobals $ORG $PEER
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel join -b $BLOCKFILE >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, $PEER.$ORG has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
  ORG=$1
	PEER=$2
  docker exec cli ./scripts/setAnchorPeer.sh $ORG $PEER $CHANNEL_NAME 
}

FABRIC_CFG_PATH=${PWD}/config

# Create channeltx
infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTx

BLOCKFILE="./config/network-config/${CHANNEL_NAME}.block"

# Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

# Join all the peers to the channel
infoln "Joining TnOrg peer to the channel..."
joinChannel "tn" "endorser"
joinChannel "tn" "peer0"
joinChannel "tn" "peer1"
infoln "Joining TcOrg peer to the channel..."
joinChannel "tc" "endorser"
joinChannel "tc" "peer0"
joinChannel "tc" "peer1"


# Set the anchor peers for each org in the channel
infoln "Setting anchor peer for TnOrg..."
setAnchorPeer "tn" "endorser"
infoln "Setting anchor peer for TcOrg..."
setAnchorPeer "tc" "endorser"

successln "Channel '$CHANNEL_NAME' joined"
