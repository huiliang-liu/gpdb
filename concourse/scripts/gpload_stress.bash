#!/bin/bash -l

set -eox pipefail
export HOME_DIR=$PWD


function setup_gpadmin_user() {
    ./gpdb_src/concourse/scripts/setup_gpadmin_user.bash "$TEST_OS"
}

function install_gpdb() {
    [ ! -d $GPDB_PREFIX ] && mkdir -p $GPDB_PREFIX
    tar -xzf bin_gpdb/$BIN_GPDB_NAME.tar.gz -C $GPDB_PREFIX
}

function setup_cluster() {
    export CONFIGURE_FLAGS="--enable-gpfdist --with-openssl"
case "${TARGET_OS}" in
    ubuntu*)
	export BIN_GPDB_NAME=compiled_bits_ubuntu16
        export GPDB_PREFIX=/usr/local/gpdb
        export TEST_OS=ubuntu
        source $HOME_DIR/gpdb_src/concourse/scripts/ubuntu_gpdb_common.bash
        ;;
    centos*);&
    *)
        source $HOME_DIR/gpdb_src/concourse/scripts/common.bash
        export BIN_GPDB_NAME=bin_gpdb
        export GPDB_PREFIX=/usr/local/greenplum-db-devel
        export TEST_OS=centos
        source /opt/gcc_env.sh
        ;;
esac
    time install_and_configure_gpdb
    time setup_gpadmin_user
    export WITH_MIRRORS=false
    time make_cluster
    source $GPDB_PREFIX/greenplum_path.sh
    source $HOME_DIR/gpdb_src/gpAux/gpdemo/gpdemo-env.sh
}

function gpload_stress() {
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

function gpfdist_test() {
    cd $HOME_DIR/gpdb_src/src/test/regress
    make
    chown -R gpadmin:gpadmin $HOME_DIR/gpdb_src/src/bin/gpfdist
    cd $HOME_DIR/gpdb_src/src/bin/gpfdist
    make install
    su gpadmin -c "source ${GPDB_PREFIX}/greenplum_path.sh && make installcheck"
}

function _main() {
    setup_cluster
    gpfdist_test
}

_main "$@"
