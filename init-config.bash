#!/bin/bash

BLUE='\033[0;34m'
LBLUE='\033[1;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW=$(tput setaf 3)
CYAN1='\033[38;5;50m'
NC='\033[0m' # No Color
BOLD_ON='\033[1m'
BOLD_OFF='\033[22m'
CLEAR='\033[2J'

projectEnvFile=${1:-'project.env'}

function checkProjectEnvFile () {
  if [ -f "$projectEnvFile" ]; then
      printf "${CYAN1}- File '${projectEnvFile}' found in: ${NC}$PWD\n"
      return 0
  else
      printf "${RED}No ${BOLD_ON}'${projectEnvFile}'${BOLD_OFF} file found in: ${NC}$PWD\n"
      printf "${YELLOW}Please create copy of ${BOLD_ON}'project.env.dist'${BOLD_OFF} as ${BOLD_ON}'project.env'${BOLD_OFF} and fill the placeholders ${NC}\n"
      return 1
  fi
}

printf "${CYAN1}Init configuration files:${NC}\n"
checkProjectEnvFile

# squid
printf "${CYAN1}- Processing ${BOLD_ON}'squid'${BOLD_OFF} configuration${NC}"
sed -e "s|\$SQUID_PORT|$SQUID_PORT|g" \
    -e "s|\$DNSMASQ_IP|$DNSMASQ_IP|g" \
     ./squid/squid.conf.dist > ./squid/squid.conf

printf ": ${GREEN}DONE${NC}\n"

# dnsmasq
printf "${CYAN1}- Processing ${BOLD_ON}'dnsmasq'${BOLD_OFF} configuration${NC}"
sed -e "s|\$NGINX_PROXY_MANAGER_IP|$NGINX_PROXY_MANAGER_IP|g" \
    -e "s|\$SQUID_IP|$SQUID_IP|g" \
    -e "s|\$SQUID_PORT|$SQUID_PORT|g" \
    -e "s|\$DOMAIN_NAME|$DOMAIN_NAME|g" \
     ./dnsmasq/dnsmasq.conf.dist > ./dnsmasq/dnsmasq.conf
printf ": ${GREEN}DONE${NC}\n"