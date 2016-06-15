Name:           dci-pgbackup
Version:        0.1
Release:        2%{?dist}

Summary:        Distributed CI Team PG backup utility
License:        ASL2.0
URL:            https://github.com/redhat-cip/dci-pgbackup
Source0:        dci_pgbackup.conf
Source1:        dci_pgbackup.sh
Source2:        dci_pgbackup_cron

BuildArch:      noarch

Requires:       postgresql
Requires:       python-swiftclient

%description
This package contains a set of file to automate the backup of a postgresql database

%prep

%build

%install
install -d %{buildroot}/%{_sysconfdir}/
install -m 0644 %{SOURCE0} %{buildroot}/%{_sysconfdir}/dci_pgbackup.conf

install -d %{buildroot}/%{_sysconfdir}/cron.d/
install -m 0644 %{SOURCE2} %{buildroot}/%{_sysconfdir}/cron.d/dci_pgbackup

install -d %{buildroot}/%{_usr}/local/bin
install %{SOURCE1} %{buildroot}/%{_usr}/local/bin/dci_pgbackup.sh


%files
%defattr(-,root,root,-)
%{_sysconfdir}/dci_pgbackup.conf
%{_sysconfdir}/cron.d/dci_pgbackup
%attr(755, %{username}, %{username}) /home/%{username}/dci_pgbackup.sh

%changelog
* Wed Jun 15 2016 Yanis Guenane <yguenane@redhat.com> 0.1-2
- Rely on swift to upload the backup
* Wed Apr 6 2016 Yanis Guenane <yguenane@redhat.com> 0.1-1
- Initial commit
