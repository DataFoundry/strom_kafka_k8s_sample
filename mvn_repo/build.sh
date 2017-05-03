#!/bin/bash
set -o pipefail
IFS=$'\n\t'

if [[ "${SOURCE_REPOSITORY}" != "git://"* ]] && [[ "${SOURCE_REPOSITORY}" != "git@"* ]]; then
  URL="${SOURCE_REPOSITORY}"
  if [[ "${URL}" != "http://"* ]] && [[ "${URL}" != "https://"* ]]; then
    URL="https://${URL}"
  fi
  curl --head --silent --fail --location --max-time 16 $URL > /dev/null
  if [ $? != 0 ]; then
    echo "Could not access source url: ${SOURCE_REPOSITORY}"
    exit 1
  fi
fi

if [ -n "${SOURCE_REF}" ]; then
  BUILD_DIR=$(mktemp --directory)
  git clone --recursive "${SOURCE_REPOSITORY}" "${BUILD_DIR}"
  if [ $? != 0 ]; then
    echo "Error trying to fetch git source: ${SOURCE_REPOSITORY}"
    exit 1
  fi
  pushd "${BUILD_DIR}"
  git checkout "${SOURCE_REF}"
  if [ $? != 0 ]; then
    echo "Error trying to checkout branch: ${SOURCE_REF}"
    exit 1
  fi
  pwd
  ls
  sed  "s|#STORMCLASSNAME#|${STORMCLASSNAME}|g" "${BUILD_DIR}"/src/main/java/PlatFormTestTopo.java.tpl > "${BUILD_DIR}"/src/main/java/"${STORMCLASSNAME}".java
  
  sed -i "s|#KAFKAZKIP#|${KAFKAZKIP}|g" "${BUILD_DIR}"/src/main/resources/config.properties
  sed -i "s|#KAFKAZKPORT#|${KAFKAZKPORT}|g" "${BUILD_DIR}"/src/main/resources/config.properties
  sed -i "s|#KAFKAZKROOT#|${KAFKAZKROOT}|g" "${BUILD_DIR}"/src/main/resources/config.properties
  sed -i "s|#KAFKAZKIPPORT#|${KAFKAZKIPPORT}|g" "${BUILD_DIR}"/src/main/resources/config.properties
  sed -i "s|#KAFKACONSUMERID#|${KAFKACONSUMERID}|g" "${BUILD_DIR}"/src/main/resources/config.properties
  sed -i "s|#KAFKATOPIC#|${KAFKATOPIC}|g" "${BUILD_DIR}"/src/main/resources/config.properties
  
  sed -i "s|#STORMJARNAME#|${STORMJARNAME}|g" "${BUILD_DIR}"/pom.xml
  sed -i "s|#STORMJARVER#|${STORMJARVER}|g" "${BUILD_DIR}"/pom.xml
  
  cat "${BUILD_DIR}"/src/main/resources/config.properties
  
  mvn package
  /opt/apache-storm/bin/storm jar target/"${STORMJARNAME}"-"${STORMJARVER}".jar "${STORMCLASSNAME}" "${STROMNHOST}" 
else
  docker build --rm -t "${TAG}" "${SOURCE_REPOSITORY}"
fi
