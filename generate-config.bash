#!/bin/bash
source ./devops/local/scripts/blablo.sh
source ./devops/local/scripts/checkProjectEnvFile.sh

BLUE='\033[0;34m'
LBLUE='\033[1;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW=$(tput setaf 3)
CYAN1='\033[38;5;51m'
NC='\033[0m' # No Color
BOLD_ON='\033[1m'
BOLD_OFF='\033[22m'

projectEnvFile=${1:-'project.env'}

blablo.cleanLog "🎯 Init configuration files"
checkProjectEnvFile "${projectEnvFile}"

# squid
blablo.log "Processing ${CYAN1}'squid'${NC} configuration"
sed -e "s|\$SQUID_PORT|$SQUID_PORT|g" \
    -e "s|\$DNSMASQ_IP|$DNSMASQ_IP|g" \
     ./squid/squid.conf.dist > ./squid/squid.conf
blablo.chainLog "${GREEN}DONE${NC}"
blablo.finish

# dnsmasq
blablo.log "Processing ${CYAN1}'dnsmasq'${NC} configuration"
sed -e "s|\$NGINX_PROXY_MANAGER_IP|$NGINX_PROXY_MANAGER_IP|g" \
    -e "s|\$SQUID_IP|$SQUID_IP|g" \
    -e "s|\$SQUID_PORT|$SQUID_PORT|g" \
    -e "s|\$DOMAIN_NAME|$DOMAIN_NAME|g" \
     ./dnsmasq/dnsmasq.conf.dist > ./dnsmasq/dnsmasq.conf
blablo.chainLog "${GREEN}DONE${NC}"
blablo.finish

blablo.cleanLog "🎯 Done ✨"