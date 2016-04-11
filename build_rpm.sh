#!/bin/bash
set -eux
PROJ_NAME=dci-pgbackup

# Configure rpmmacros to enable signing packages
#
echo '%_signature gpg' >> ~/.rpmmacros
echo '%_gpg_name Distributed-CI' >> ~/.rpmmacros

# Create the proper filesystem hierarchy to proceed with srpm creatioon
#
rpmdev-setuptree
cp ${PROJ_NAME}.spec ${HOME}/rpmbuild/SPECS/
cp -r {dci_pgbackup.conf,dci_pgbackup_logrotate,dci_pgbackup.sh,dci_pgbackup_cron} ${HOME}/rpmbuild/SOURCES/
cp -r ssh/{dci_pgbackup,dci_pgbackup.pub} ${HOME}/rpmbuild/SOURCES/
rpmbuild -bs ${HOME}/rpmbuild/SPECS/${PROJ_NAME}.spec

# Build the RPMs in a clean chroot environment with mock to detect missing
# BuildRequires lines.
for arch in fedora-23-x86_64 epel-7-x86_64; do

    if [[ "$arch" == "fedora-23-x86_64" ]]; then
        RPATH='fedora/23/x86_64'
    else
        RPATH='el/7/x86_64'
    fi

    # NOTE(spredzy): Add signing options
    #
    mkdir -p ${HOME}/.mock
    cp /etc/mock/${arch}.cfg ${HOME}/.mock/${arch}-with-sign.cfg
    sed -i "\$aconfig_opts['plugin_conf']['sign_enable'] = True" ${HOME}/.mock/${arch}-with-sign.cfg
    sed -i "\$aconfig_opts['plugin_conf']['sign_opts'] = {}" ${HOME}/.mock/${arch}-with-sign.cfg
    sed -i "\$aconfig_opts['plugin_conf']['sign_opts']['cmd'] = 'rpmsign'" ${HOME}/.mock/${arch}-with-sign.cfg
    sed -i "\$aconfig_opts['plugin_conf']['sign_opts']['opts'] = '--addsign %(rpms)s'" ${HOME}/.mock/${arch}-with-sign.cfg

    mkdir -p current
    mock -r ${HOME}/.mock/${arch}-with-sign.cfg rebuild --resultdir=current/${RPATH} ${HOME}/rpmbuild/SRPMS/${PROJ_NAME}*
done
