#!/bin/bash
export TEST_NETWORK_HOME=$(dirname $(realpath -s $0))
export BIN_DIR="${TEST_NETWORK_HOME}/bin"
export LOG_DIR="${TEST_NETWORK_HOME}/log"
export FABRIC_CFG_PATH=${TEST_NETWORK_HOME}/config

function startPeer() {

    export FABRIC_LOGGING_SPEC="INFO"
    #export FABRIC_LOGGING_SPEC="DEBUG"
    export CORE_VM_ENDPOINT=""
    export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=""
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_MSPCONFIGPATH="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp"
    export CORE_PEER_TLS_CERT_FILE="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt"
    export CORE_PEER_TLS_KEY_FILE="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key"
    export CORE_PEER_TLS_ROOTCERT_FILE="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
    export CORE_PEER_ID="peer0.org1.example.com"
    export CORE_PEER_ADDRESS="peer0.org1.example.com:7051"
    export CORE_PEER_LISTENADDRESS="0.0.0.0:7051"
    # export CORE_PEER_CHAINCODEADDRESS="peer0.org1.example.com:7052"
    export CORE_PEER_CHAINCODELISTENADDRESS="peer0.org1.example.com:7052"
    export CORE_PEER_GOSSIP_BOOTSTRAP="peer0.org1.example.com:7051"
    export CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.org1.example.com:7051"
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_OPERATIONS_LISTENADDRESS="0.0.0.0:7445"
    export CORE_PEER_FILESYSTEMPATH="${TEST_NETWORK_HOME}/production/peers/peer0.org1.example.com"
    export CORE_LEDGER_SNAPSHOTS_ROOTDIR="${TEST_NETWORK_HOME}/production/peers/peer0.org1.example.com/snapshots"

    nohup sh -c '${BIN_DIR}/peer node start' >${LOG_DIR}/peer.log 2>&1 &
    echo $!
}

startPeer
