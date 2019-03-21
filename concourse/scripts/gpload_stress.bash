#!/bin/bash -l

set -eox pipefail
export HOME_DIR=$PWD

source $HOME_DIR/gpdb_src/concourse/scripts/common.bash

function setup_gpadmin_user() {
    ./gpdb_src/concourse/scripts/setup_gpadmin_user.bash "$TEST_OS"
}

function install_gpdb() {
    [ ! -d $GPDB_PREFIX ] && mkdir -p $GPDB_PREFIX
    tar -xzf bin_gpdb/$BIN_GPDB_NAME.tar.gz -C $GPDB_PREFIX
}

function setup_cluster() {
    export CONFIGURE_FLAGS="--enable-gpfdist --with-openssl"
    export TEST_OS=centos
    export BIN_GPDB_NAME=bin_gpdb
    export GPDB_PREFIX=/usr/local/greenplum-db-devel
    source /opt/gcc_env.sh
    time install_and_configure_gpdb
    time setup_gpadmin_user
    time make_cluster
    source $GPDB_PREFIX/greenplum_path.sh
    source $HOME_DIR/gpdb_src/gpAux/gpdemo/gpdemo-env.sh
}

function _main() {
    setup_cluster
    chown -R gpadmin:gpadmin $HOME_DIR/gpdb_src/gpMgmt/bin/gpload_test/gpload2
    export USER=gpadmin
    export PGUSER=gpadmin
    cp -f $HOME_DIR/gpdb_src/gpMgmt/bin/gpload.py $GPDB_PREFIX/bin/gpload.py
    cd $HOME_DIR/gpdb_src/gpMgmt/bin/gpload_test/gpload2
    while [ $? -eq 0 ]
    do
        su gpadmin -c "python TEST.py"
    done
}

_main "$@"
