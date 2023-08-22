#!/usr/bin/env bash

BLUE='\033[0;34m'
LBLUE='\033[1;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW=$(tput setaf 3)
NC='\033[0m' # No Color

projectEnvFile=${1:-'project.env'}

function checkProjectEnvFile () {
  if [ -f "$projectEnvFile" ]; then
      return 0
  else
      printf "${RED}No ${projectEnvFile} file found in: ${NC}$PWD\n"
      return 1
  fi
}

function checkVar () {
    printf "$1 ";

    eval value='$'$1

    if [ -z "$value" ]
    then
        printf "${RED}[NOT FOUND]${NC}\n";
        return 1
    else
        printf "= $value"
        printf " ${GREEN}[OK]${NC}\n";
        return 0
    fi
}

printf "${LBLUE}Gonna check env vars...${NC}\n";

checkProjectEnvFile

varNamesString=$(sed 's/=.*$//' $projectEnvFile)
IFS=$'\n' read -rd '' -a varsToCheck <<< "$varNamesString"

for var in "${varsToCheck[@]}"; do
    checkVar "$var"
done

printf "${LBLUE}Check completed${NC}\n";
echo " ";