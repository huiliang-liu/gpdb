#!/bin/bash -l

set -eox pipefail

export GREENPLUM_INSTALL_DIR=$GPDB_PREFIX

function configure() {
  pushd gpdb_src
    # TODO: remove this line as soon as zstd is vendored in the installer for ubuntu
    CONFIGURE_FLAGS="${CONFIGURE_FLAGS} --without-zstd"
    ./configure --prefix=${GREENPLUM_INSTALL_DIR} --with-gssapi --with-perl \
          --with-python --with-libxml --enable-mapreduce --enable-orafce \
          --disable-orca --enable-pxf ${CONFIGURE_FLAGS}
  popd
}

function install_and_configure_gpdb() {
  install_gpdb
  configure
}

function make_cluster() {
  source "${GREENPLUM_INSTALL_DIR}/greenplum_path.sh"
  pushd gpdb_src/gpAux/gpdemo
    su gpadmin -c "source ${GREENPLUM_INSTALL_DIR}/greenplum_path.sh && make create-demo-cluster"
  popd
}
