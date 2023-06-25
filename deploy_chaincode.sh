#!/bin/bash
export TEST_NETWORK_HOME=$(dirname $(realpath -s $0))
export BIN_DIR="${TEST_NETWORK_HOME}/bin"
export LOG_DIR="${TEST_NETWORK_HOME}/log"
export FABRIC_CFG_PATH=${TEST_NETWORK_HOME}/config
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA="${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
export CORE_PEER_ADDRESS="peer0.org1.example.com:7051"
export CHANNEL_NAME=mychannel0
export CHAINCODE_INIT_REQUIRED=""
export CHAINCODE_END_POLICY=""
export CHAINCODE_COLL_CONFIG=""
export MAX_RETRY=5
export DELAY=2
function deployChaincode() {
    CHAINCODE_NAME=$1
    CHAINCODE_VERSION=$2
    CHAINCODE_SEQUENCE=$3
    CHAINCODE_PATH=${TEST_NETWORK_HOME}/chaincodes/chaincode/${CHAINCODE_NAME}
    CHAINCODE_PACKAGE_PATH=${TEST_NETWORK_HOME}/packages/${CHAINCODE_NAME}.tar.gz
    LOG_PATH=${LOG_DIR}/${CHAINCODE_NAME}.log
    pushd ${CHAINCODE_PATH}
    GO111MODULE=on go mod vendor
    popd
    echo "Finished vendoring Go dependencies"

    set -x
    ${BIN_DIR}/peer lifecycle chaincode package ${CHAINCODE_PACKAGE_PATH} --path ${CHAINCODE_PATH} --lang "golang" --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&${LOG_PATH}
    res=$?
    { set +x; } 2>/dev/null
    cat ${LOG_PATH}
    verifyResult $res "Chaincode packaging has failed"
    echo "Chaincode is packaged"

    set -x
    ${BIN_DIR}/peer lifecycle chaincode install ${CHAINCODE_PACKAGE_PATH} >&${LOG_PATH}
    res=$?
    { set +x; } 2>/dev/null
    cat ${LOG_PATH}
    verifyResult $res "Chaincode installation on peer0.org${ORG} has failed"
    echo "Chaincode is installed on peer0.org1"

    set -x
    ${BIN_DIR}/peer lifecycle chaincode queryinstalled >&${LOG_PATH}
    res=$?
    { set +x; } 2>/dev/null
    cat ${LOG_PATH}
    PACKAGE_ID=$(sed -n "/${CHAINCODE_NAME}_${CHAINCODE_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" ${LOG_PATH})
    verifyResult $res "Query installed on peer0.org1 has failed"
    echo "Query installed successful on peer0.org1 on channel"

    set -x
    ${BIN_DIR}/peer lifecycle chaincode approveformyorg -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile $ORDERER_CA --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --package-id ${PACKAGE_ID} --sequence ${CHAINCODE_SEQUENCE} ${CHAINCODE_INIT_REQUIRED} ${CHAINCODE_END_POLICY} ${CHAINCODE_COLL_CONFIG} >&${LOG_PATH}
    res=$?
    { set +x; } 2>/dev/null
    cat ${LOG_PATH}
    verifyResult $res "Chaincode definition approved on peer0.org1 on channel '${CHANNEL_NAME}' failed"
    echo "Chaincode definition approved on peer0.org1 on channel '${CHANNEL_NAME}'"

    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    shift 3
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        echo "Attempting to check the commit readiness of the chaincode definition on peer0.org1, Retry after $DELAY seconds."
        set -x
        ${BIN_DIR}/peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} ${CHAINCODE_INIT_REQUIRED} ${CHAINCODE_END_POLICY} ${CHAINCODE_COLL_CONFIG} --output json >&${LOG_PATH}
        res=$?
        { set +x; } 2>/dev/null
        let rc=0
        for var in "$@"; do
            grep "$var" ${LOG_PATH} &>/dev/null || let rc=1
        done
        COUNTER=$(expr $COUNTER + 1)
    done
    cat ${LOG_PATH}
    if test $rc -eq 0; then
        echo "Checking the commit readiness of the chaincode definition successful on peer0.org on channel '${CHANNEL_NAME}'"
    else
        echo "After $MAX_RETRY attempts, Check commit readiness result on peer0.org1 is INVALID!"
        exit 1
    fi

    PEER_CONN_PARMS="${PEER_CONN_PARMS} --peerAddresses ${CORE_PEER_ADDRESS}"
    TLSINFO=$(eval echo "--tlsRootCertFiles \$CORE_PEER_TLS_ROOTCERT_FILE")
    PEER_CONN_PARMS="${PEER_CONN_PARMS} ${TLSINFO}"
    # while 'peer chaincode' command can get the orderer endpoint from the
    # peer (if join was successful), let's supply it directly as we know
    # it using the "-o" option
    set -x
    ${BIN_DIR}/peer lifecycle chaincode commit -o orderer0.example.com:7050 --ordererTLSHostnameOverride orderer0.example.com --tls --cafile $ORDERER_CA --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} $PEER_CONN_PARMS --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} ${CHAINCODE_INIT_REQUIRED} ${CHAINCODE_END_POLICY} ${CHAINCODE_COLL_CONFIG} >&${LOG_PATH}
    res=$?
    { set +x; } 2>/dev/null
    cat ${LOG_PATH}
    verifyResult $res "Chaincode definition commit failed on peer0.org1 on channel '${CHANNEL_NAME}' failed"
    echo "Chaincode definition committed on channel '${CHANNEL_NAME}'"

    EXPECTED_RESULT="Version: ${CHAINCODE_VERSION}, Sequence: ${CHAINCODE_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    echo "Querying chaincode definition on peer0.org$ on channel '${CHANNEL_NAME}'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        echo "Attempting to Query committed status on peer0.org1, Retry after $DELAY seconds."
        set -x
        ${BIN_DIR}/peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} >&${LOG_PATH}
        res=$?
        { set +x; } 2>/dev/null
        test $res -eq 0 && VALUE=$(cat ${LOG_PATH} | grep -o '^Version: '$CHAINCODE_VERSION', Sequence: [0-9]*, Endorsement Plugin: escc, Validation Plugin: vscc')
        test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
        COUNTER=$(expr $COUNTER + 1)
    done
    cat ${LOG_PATH}
    if test $rc -eq 0; then
        echo "Query chaincode definition successful on peer0.org1 on channel '${CHANNEL_NAME}'"
    else
        echo "After $MAX_RETRY attempts, Query chaincode definition result on peer0.org1 is INVALID!"
        exit 1
    fi
}

function verifyResult() {
    if [ $1 -ne 0 ]; then
        echo -e "$2"
        exit 1
    fi
}

function main() {
    deployChaincode token-erc-20 1.0 1
    deployChaincode token-erc-721 1.0 1
    deployChaincode token-erc-1155 1.0 1
    deployChaincode token-erc-utxo 1.0 1
}
main
