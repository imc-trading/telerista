#!/bin/bash
set -ex

REPOSITORY=${REPOSITORY:-docker.io}
IMAGE=${IMAGE:-telerista}
TAG=${TAG:-build}
BUILD=${REPOSITORY}/${IMAGE}:${TAG}

tags=()
if [ ! "$TAG" == "build" ]; then
  tags+=($TAG)
fi

log_msg() {
  echo "[$(date "+%Y/%m/%d %H:%M:%S %z")] $@"
}

docker_build() {
  if [ ! -z "$BUILD_NUMBER" ]; then
    # This is a TC build
    tags+=("$BUILD_NUMBER", "latest")
    docker build --no-cache "$@"
  else
    docker build "$@"
  fi
}


if ! docker_build -t ${BUILD} .; then
  log_msg "Build failed!"
else
  log_msg "Build succeeded!"
  for tag in ${tags[@]}; do
    docker tag ${REPOSITORY}/${IMAGE}:${TAG} ${REPOSITORY}/${IMAGE}:${tag}
  done
fi
