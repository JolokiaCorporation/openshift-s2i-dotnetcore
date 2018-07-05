#!/bin/bash
#
# Build Docker images and run tests.
#
# PRE: Docker daemon running, s2i binary available.
#
# Supported environment variables:
#
# -----------------------------------------------------
# TEST_OPENSHIFT  If 'true' run tests to make sure
#                 released images work against the
#                 test application used in OpenShift
#
# VERSIONS     The list of versions to build/test.
#              Defaults to all versions. i.e "1.0 1.1".
#
# BUILD_CENTOS    If 'true' build CentOS based images.
# -----------------------------------------------------
#
# Usage:
#       $ sudo ./build.sh
#       $ sudo VERSIONS=1.0 ./build.sh
#
if [ "${DEBUG}" == "true" ]; then
  set -x
fi

base_image_name() {
  local version=$1
  local v_no_dot=$(echo ${version} | sed 's/\.//g')
  echo "ubuntu-dotnet:${version}";
}

image_exists() {
  docker inspect $1 &>/dev/null
}

check_result_msg() {
  local retval=$1
  local msg=$2
  if [ ${retval} -ne 0 ]; then
    echo 1>&2 "${msg}"
    exit 1
  fi
}

build_image() {
  local path=$1
  local docker_filename=$2
  local name=$3
  if ! image_exists ${name}; then
    echo "Building Docker image ${name} ..."
    if [ ! -d "${path}" ]; then
      echo "No directory found at given location '${path}'. Skipping this image."
      return
    fi
    pushd ${path} &>/dev/null
      /mnt/c/Program\ Files/Docker/Docker/resources/bin/docker.exe build -f ${docker_filename} -t ${name} .
      check_result_msg $? "Building Docker image ${name} FAILED!"
	  /mnt/c/Program\ Files/Docker/Docker/resources/bin/docker.exe push ${name}
	  check_result_msg $? "Pushing Docker image ${name} FAILED!"
    popd &>/dev/null
  fi
}

test_images() {
  local path=$1
  local test_image=$2
  local runtime_image=$3
  echo "Running tests..."
  IMAGE_NAME=${test_image} RUNTIME_IMAGE_NAME=${runtime_image} ${path}/run
  check_result_msg $? "Tests FAILED!"
}

  VERSIONS="${VERSIONS:-1.0 2.0}"
  image_os="ubuntu"
  image_prefix="openshift"
  docker_filename="Dockerfile"
  registry_name="docker-registry-default.apps.osp01.sntcca01.jolokia.net:443"

for v in ${VERSIONS}; do
    build_name="${registry_name}/${image_prefix}/$(base_image_name ${v})"
   
    # Build the build image
    build_image "${v}/build" "${docker_filename}" "${build_name}"
done

echo "ALL builds and tests were successful!"
exit 0
