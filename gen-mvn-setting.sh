#!/bin/bash
command -v jq >/dev/null 2>&1 || { echo >&2 "ERROR: Script requires jq but it's not installed.  Aborting."; exit 1; }
command -v az >/dev/null 2>&1 || { echo >&2 "ERROR: Script requires az but it's not installed.  Aborting."; exit 1; }
echo "Creating ServicePrincipal for deploying to Azure.."
export SP_JSON=`az ad sp create-for-rbac --name="maven-appservice-sp" --role="Contributor"`
export SP_TENANT=`echo $SP_JSON | jq -r '.tenant'`
export SP_PASS=`echo $SP_JSON | jq -r '.password'`
export SP_ID=`echo $SP_JSON | jq -r '.appId'`
cat << EOF > settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
 <servers>
   <server>
     <id>azure-auth</id>
      <configuration>
         <client>$SP_ID</client>
         <tenant>$SP_TENANT</tenant>
         <key>$SP_PASS</key>
         <environment>AZURE</environment>
      </configuration>
   </server>
 </servers>
</settings>
EOF


echo "Maven settings.xml created.  "
echo "================================"
echo "WARNING: Do not check-in to SCM."
echo "         Contains auth information"


