#!/usr/bin/env sh
set -e

APK_URL="$1"
CALLBACK_URL="$2"
GET_TIMEOUT=20
POST_TIMEOUT=5
CONTENT_TYPE="text/xml"
TOOL="python ./androguard_manifest.py"

# use a ramfs if possible for storing the app
[[ -d "/dev/shm" ]] && TMP_DIR="/dev/shm/" || TMP_DIR="/tmp/"

INPUT_PATH="${TMP_DIR}/android_app.apk"

( ( [[ -z "${APK_URL}" ]] && cat > "${INPUT_PATH}" ) || \
  ( [[ -e  "${APK_URL}" ]] && cat "${APK_URL}" > "${INPUT_PATH}" ) || \
  curl -m ${GET_TIMEOUT} -s "${APK_URL}" -o "${INPUT_PATH}" )

( [[ -n "${CALLBACK_URL}" ]] && \
  ${TOOL} ${INPUT_PATH} \
  | curl -m ${POST_TIMEOUT} -s -XPOST "${CALLBACK_URL}" -H "Content-Type: ${CONTENT_TYPE}" --data-binary @- ) || \
  ${TOOL} ${INPUT_PATH}

