#!/bin/bash
export TEST_NETWORK_HOME=$(dirname $(realpath -q $0))
export BIN_DIR="${TEST_NETWORK_HOME}/bin"
export LOG_DIR="${TEST_NETWORK_HOME}/log"
export FABRIC_CFG_PATH=${TEST_NETWORK_HOME}/config/peer
export ORDERER_CA="${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

CHANNEL_NAME="ch1"
CHAINCODE_NAME="mrc20-v3"


function query() {
    for var in {0..0}; do
        PEER_PORT=$(((($var + 7) * 1000) + 51))

        export CORE_PEER_MSPCONFIGPATH="${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
        export CORE_PEER_ADDRESS=chN.peer${var}.org1.example.com:${PEER_PORT}
        export CORE_PEER_TLS_CERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer${var}.org1.example.com/tls/server.crt
        export CORE_PEER_TLS_KEY_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer${var}.org1.example.com/tls/server.key
        export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer${var}.org1.example.com/tls/ca.crt

        # set PEER_CONN_PARMS
        PEER_CONN_PARMS="${PEER_CONN_PARMS} --peerAddresses ${CORE_PEER_ADDRESS}"
        TLSINFO=$(eval echo "--tlsRootCertFiles \$CORE_PEER_TLS_ROOTCERT_FILE")
        PEER_CONN_PARMS="${PEER_CONN_PARMS} ${TLSINFO}"
    done

    msg="hi"
    pub="0x03d5fd214aa631143a7167c0ba10007de6cee4c7e8351e7275e75af9abaae68be5"
    sig="0x21ff841a095bdc8f2784d4130ea3f0ac1176584831a83be3af0257d5f8549f0446e4a6539c264c106f4f6d2160b9b965e590e58e1afd80328599733a2cdd6a1c0000000000000000000000000000000000000000000000000000000000000001"

    # param="{\"Args\":[\"TestMdlSdkV3\",\"${msg}\",\"${pub}\",\"${sig}\"]}"
    param="{\"Args\":[\"TestMdlSdkV3\",\"${msg}\",\"${pub}\",\"${sig}\"]}"

    set -x
    ${BIN_DIR}/peer chaincode query -o orderer0.example.com:7050 --ordererTLSHostnameOverride chN.orderer0.example.com --tls --cafile $ORDERER_CA $PEER_CONN_PARMS -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c $param >&${LOG_DIR}/test.log
    { set +x; } 2>/dev/null

    cat ${LOG_DIR}/test.log
}

function verifyResult() {
    if [ $1 -ne 0 ]; then
        echo -e "$2"
        exit 1
    fi
}

function main() {
    query
}

main