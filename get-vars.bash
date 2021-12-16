#!/bin/bash


namespaces=court-probation-dev
services=court-case-service

# Read any named params
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

echo "🏷  Namespaces: ${namespaces}"
echo "💻 Services: ${services}"
