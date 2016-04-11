%global username dci_pgbackup

Name:           dci-pgbackup
Version:        0.1
Release:        1%{?dist}

Summary:        Distributed CI Team PG backup utility
License:        ASL2.0
URL:            https://github.com/redhat-cip/dci-pgbackup
Source0:        dci_pgbackup.conf
Source1:        dci_pgbackup_logrotate
Source2:        dci_pgbackup.sh
Source3:        ssh/dci_pgbackup
Source4:        ssh/dci_pgbackup.pub
Source5:        dci_pgbackup_cron

BuildArch:      noarch

Requires(pre):  shadow-utils
Requires:       sudo

%description
This package contains a set of file to automate the backup of a postgresql database

%prep

%build

%install
install -d %{buildroot}/%{_sysconfdir}/
install -m 0644 %{SOURCE0} %{buildroot}/%{_sysconfdir}/dci_pgbackup.conf

install -d %{buildroot}/%{_sysconfdir}/logrotate.d/
install -m 0644 %{SOURCE1} %{buildroot}/%{_sysconfdir}/logrotate.d/dci_pgbackup

install -d %{buildroot}/%{_sysconfdir}/cron.d/
install -m 0644 %{SOURCE5} %{buildroot}/%{_sysconfdir}/cron.d/dci_pgbackup

install -d -m 700 %{buildroot}/home/%{username}/.ssh
install -m 0600 %{SOURCE3} %{buildroot}/home/%{username}/.ssh/id_rsa
install -m 0644 %{SOURCE4} %{buildroot}/home/%{username}/.ssh/id_rsa.pub

install %{SOURCE2} %{buildroot}/home/%{username}/dci_pgbackup.sh


%files
%defattr(-,root,root,-)
%{_sysconfdir}/dci_pgbackup.conf
%{_sysconfdir}/cron.d/dci_pgbackup
%{_sysconfdir}/logrotate.d/dci_pgbackup
%attr(755, %{username}, %{username}) /home/%{username}/dci_pgbackup.sh
%attr(700, %{username}, %{username}) /home/%{username}/.ssh
%attr(600, %{username}, %{username}) /home/%{username}/.ssh/id_rsa
%attr(644, %{username}, %{username}) /home/%{username}/.ssh/id_rsa.pub

%pre
getent group %{username} >/dev/null || groupadd -r %{username}
getent passwd %{username} >/dev/null || \
    useradd -r -g %{username} -d /home/%{username} -s /bin/bash \
    -c "The DCI PG backup user" -m %{username}
exit 0

%changelog
* Wed Apr 6 2016 Yanis Guenane <yguenane@redhat.com> 0.1-1
- Initial commit
