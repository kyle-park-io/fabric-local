#!/bin/bash
export TEST_NETWORK_HOME=$(dirname $(realpath -s $0))
export BIN_DIR="${TEST_NETWORK_HOME}/bin"
export LOG_DIR="${TEST_NETWORK_HOME}/log"
export FABRIC_CFG_PATH=${TEST_NETWORK_HOME}/config

function startOrderer() {

    export FABRIC_LOGGING_SPEC="INFO"
    #export FABRIC_LOGGING_SPEC="DEBUG"
    export ORDERER_GENERAL_LISTENADDRESS="0.0.0.0"
    export ORDERER_GENERAL_LISTENPORT="7050"
    # export ORDERER_GENERAL_GENESISMETHOD=file
    # export ORDERER_GENERAL_GENESISFILE=${TEST_NETWORK_HOME}/channel-artifacts/genesis.block
    export ORDERER_GENERAL_BOOTSTRAPMETHOD="file"
    export ORDERER_GENERAL_BOOTSTRAPFILE="${TEST_NETWORK_HOME}/channel-artifacts/genesis.block"
    export ORDERER_GENERAL_LOCALMSPID="OrdererMSP"
    export ORDERER_GENERAL_LOCALMSPDIR="${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp"
    export ORDERER_OPERATIONS_LISTENADDRESS="0.0.0.0:7444"
    export ORDERER_GENERAL_TLS_ENABLED=true
    export ORDERER_GENERAL_TLS_PRIVATEKEY="${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/tls/server.key"
    export ORDERER_GENERAL_TLS_CERTIFICATE="${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/tls/server.crt"
    export ORDERER_GENERAL_TLS_ROOTCAS=["${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/tls/ca.crt"]
    export ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
    export ORDERER_KAFKA_VERBOSE=true
    # export ORDERER_GENERAL_CLUSTER_LISTENADDRESS=orderer.example.com
    # export ORDERER_GENERAL_CLUSTER_LISTENPORT=7050
    # export ORDERER_GENERAL_CLUSTER_SERVERCERTIFICATE=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
    # export ORDERER_GENERAL_CLUSTER_SERVERPRIVATEKEY=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
    # export ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
    # export ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
    # export ORDERER_GENERAL_CLUSTER_ROOTCAS=[${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt]
    export ORDERER_FILELEDGER_LOCATION="${TEST_NETWORK_HOME}/production/orderers/orderer0.example.com"
    export ORDERER_CONSENSUS_WALDIR="${TEST_NETWORK_HOME}/production/orderers/orderer0.example.com/etcdraft/wal"
    export ORDERER_CONSENSUS_SNAPDIR="${TEST_NETWORK_HOME}/production/orderers/orderer0.example.com/etcdraft/snapshot"

    nohup sh -c '${BIN_DIR}/orderer' >${LOG_DIR}/orderer.log 2>&1 &
    echo $!
}

startOrderer
