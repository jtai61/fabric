#!/bin/bash

source scripts/utils.sh

CHANNEL_NAME=${1:-"channel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

FABRIC_CFG_PATH=${PWD}/config

#User has not provided a name
if [ -z "$CC_NAME" ] || [ "$CC_NAME" = "NA" ]; then
  fatalln "No chaincode name was provided. Valid call example: ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go"

# User has not provided a path
elif [ -z "$CC_SRC_PATH" ] || [ "$CC_SRC_PATH" = "NA" ]; then
  fatalln "No chaincode path was provided. Valid call example: ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go"

# User has not provided a language
elif [ -z "$CC_SRC_LANGUAGE" ] || [ "$CC_SRC_LANGUAGE" = "NA" ]; then
  fatalln "No chaincode language was provided. Valid call example: ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go"

## Make sure that the path to the chaincode exists
elif [ ! -d "$CC_SRC_PATH" ]; then
  fatalln "Path to chaincode does not exist. Please provide different path."
fi

CC_SRC_LANGUAGE=$(echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:])

# do some language specific preparation to the chaincode before packaging
if [ "$CC_SRC_LANGUAGE" = "javascript" ]; then
  CC_RUNTIME_LANGUAGE=node
else
  fatalln "The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script. Supported chaincode languages are: go, java, javascript, and typescript"
  exit 1
fi

INIT_REQUIRED="--init-required"
# check if the init fcn should be called
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

# import utils
. scripts/envVar.sh

packageChaincode() {
  set -x
  peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION} >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Chaincode packaging has failed"
  successln "Chaincode is packaged"
}

# 在指定的peer上安裝鏈碼
# installChaincode PEER ORG
installChaincode() {
  ORG=$1
  PEER=$2
  setGlobals $ORG $PEER
  set -x
  peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Chaincode installation on $PEER.$ORG has failed"
  successln "Chaincode is installed on $PEER.$ORG"
}

# 查詢指定peer上已經安裝的鏈碼
# queryInstalled PEER ORG
queryInstalled() {
  ORG=$1
  PEER=$2
  setGlobals $ORG $PEER
  set -x
  peer lifecycle chaincode queryinstalled >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
  verifyResult $res "Query installed on $PEER.$ORG has failed"
  successln "Query installed successful on $PEER.$ORG on channel"
}

# 一旦鏈碼包在peer節點上安裝後，就可以代表機構審批鏈碼定義。在鏈碼定義中包含了鏈碼治理的重要參數，包括鏈碼名稱、版本和背書策略等。
# approveForMyOrg VERSION PEER ORG
approveForMyOrg() {
  ORG=$1
  PEER=$2
  setGlobals $ORG $PEER
  set -x
  peer lifecycle chaincode approveformyorg -o orderer0.edu.tw:7050 --ordererTLSHostnameOverride orderer0.edu.tw --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Chaincode definition approved on $PEER.$ORG on channel '$CHANNEL_NAME' failed"
  successln "Chaincode definition approved on $PEER.$ORG on channel '$CHANNEL_NAME'"
}

# checkCommitReadiness VERSION PEER ORG
checkCommitReadiness() {
  ORG=$1
  PEER=$2
  shift 2
  setGlobals $ORG $PEER
  infoln "Checking the commit readiness of the chaincode definition on $PEER.$ORG on channel '$CHANNEL_NAME'..."
  local rc=1
  local COUNTER=1
  # continue to poll
  # we either get a successful response, or reach MAX RETRY
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    infoln "Attempting to check the commit readiness of the chaincode definition on $PEER.$ORG, Retry after $DELAY seconds."
    set -x
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    let rc=0
    for var in "$@"; do
      grep "$var" log.txt &>/dev/null || let rc=1
    done
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  if test $rc -eq 0; then
    infoln "Checking the commit readiness of the chaincode definition successful on $PEER.$ORG on channel '$CHANNEL_NAME'"
  else
    fatalln "After $MAX_RETRY attempts, Check commit readiness result on $PEER.$ORG is INVALID!"
  fi
}

# 查看指定的鏈碼定義是否可以提交，如果後續提交可以成功，該命令將成功返回。
# 該命令同時也會輸出哪些機構已經批准了該鏈碼定義。如果一個機構已經批准了指定的鏈碼定義，該命令將返回true。
# 可以使用該命令在向通道提交鏈碼之前查看是否有足夠數量的通道成員批准了該鏈碼定義以滿足Application/Channel/Endorsement策略的要求。
# commitChaincodeDefinition VERSION PEER ORG (PEER ORG)...
commitChaincodeDefinition() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  set -x
  peer lifecycle chaincode commit -o orderer0.edu.tw:7050 --ordererTLSHostnameOverride orderer0.edu.tw --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} $PEER_CONN_PARMS --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
  successln "Chaincode definition committed on channel '$CHANNEL_NAME'"
}

# 查詢指定通道上已經提交的鏈碼。可選的，可以指定一個鏈碼名稱來查詢特定的鏈碼定義。
# queryCommitted ORG
queryCommitted() {
  ORG=$1
  PEER=$2
  setGlobals $ORG $PEER
  EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
  infoln "Querying chaincode definition on $PEER.$ORG on channel '$CHANNEL_NAME'..."
  local rc=1
  local COUNTER=1
  # continue to poll
  # we either get a successful response, or reach MAX RETRY
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    infoln "Attempting to Query committed status on $PEER.$ORG, Retry after $DELAY seconds."
    set -x
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    test $res -eq 0 && VALUE=$(cat log.txt | grep -o '^Version: '$CC_VERSION', Sequence: [0-9]*, Endorsement Plugin: escc, Validation Plugin: vscc')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  if test $rc -eq 0; then
    successln "Query chaincode definition successful on $PEER.$ORG on channel '$CHANNEL_NAME'"
  else
    fatalln "After $MAX_RETRY attempts, Query chaincode definition result on $PEER.$ORG is INVALID!"
  fi
}

# 調用指定的鏈碼，該命令將嘗試向網絡提交背書過的交易。
chaincodeInvokeInit() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  set -x
  fcn_call='{"function":"'${CC_INIT_FCN}'","Args":[]}'
  infoln "invoke fcn call:${fcn_call}"
  peer chaincode invoke -o orderer0.edu.tw:7050 --ordererTLSHostnameOverride orderer0.edu.tw --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS --isInit -c ${fcn_call} >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  successln "Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME'"
}

chaincodeQuery() {
  ORG=$1
  setGlobals $ORG
  infoln "Querying on peer0.org${ORG} on channel '$CHANNEL_NAME'..."
  local rc=1
  local COUNTER=1
  # continue to poll
  # we either get a successful response, or reach MAX RETRY
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    infoln "Attempting to Query peer0.org${ORG}, Retry after $DELAY seconds."
    set -x
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}' >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  if test $rc -eq 0; then
    successln "Query successful on peer0.org${ORG} on channel '$CHANNEL_NAME'"
  else
    fatalln "After $MAX_RETRY attempts, Query result on peer0.org${ORG} is INVALID!"
  fi
}

# package the chaincode
packageChaincode

# Install chaincode
infoln "Installing chaincode on endorser.tn..."
installChaincode "tn" "endorser"
infoln "Install chaincode on endorser.tc..."
installChaincode "tc" "endorser"

# query whether the chaincode is installed
queryInstalled "tn" "endorser"
queryInstalled "tc" "endorser"

# approve the definition for TnOrg
approveForMyOrg "tn" "endorser"

# check whether the chaincode definition is ready to be committed
# expect org1 to have approved and org2 not to
checkCommitReadiness "tn" "endorser" "\"TnMSP\": true" "\"TcMSP\": false"
checkCommitReadiness "tn" "peer0" "\"TnMSP\": true" "\"TcMSP\": false"
checkCommitReadiness "tn" "peer1" "\"TnMSP\": true" "\"TcMSP\": false"
checkCommitReadiness "tc" "endorser" "\"TnMSP\": true" "\"TcMSP\": false"
checkCommitReadiness "tc" "peer0" "\"TnMSP\": true" "\"TcMSP\": false"
checkCommitReadiness "tc" "peer1" "\"TnMSP\": true" "\"TcMSP\": false"

# now approve also for TcOrg
approveForMyOrg "tc" "endorser"

# check whether the chaincode definition is ready to be committed
# expect them both to have approved
checkCommitReadiness "tn" "endorser" "\"TnMSP\": true" "\"TcMSP\": true"
checkCommitReadiness "tn" "peer0" "\"TnMSP\": true" "\"TcMSP\": true"
checkCommitReadiness "tn" "peer1" "\"TnMSP\": true" "\"TcMSP\": true"
checkCommitReadiness "tc" "endorser" "\"TnMSP\": true" "\"TcMSP\": true"
checkCommitReadiness "tc" "peer0" "\"TnMSP\": true" "\"TcMSP\": true"
checkCommitReadiness "tc" "peer1" "\"TnMSP\": true" "\"TcMSP\": true"

# now that we know for sure both orgs have approved, commit the definition
commitChaincodeDefinition "tn" "tc"

# query on both orgs to see that the definition committed successfully
queryCommitted "tn" "endorser"
queryCommitted "tn" "peer0"
queryCommitted "tn" "peer1"
queryCommitted "tc" "endorser"
queryCommitted "tc" "peer0"
queryCommitted "tc" "peer1"

# Invoke the chaincode - this does require that the chaincode have the 'initLedger'
# method defined
if [ "$CC_INIT_FCN" = "NA" ]; then
  infoln "Chaincode initialization is not required"
else
  chaincodeInvokeInit "tn" "tc"
fi

exit 0
