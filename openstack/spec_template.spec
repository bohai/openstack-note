Name:           ConInit
Version:        0.1
Release:        1%{?dist}
Source0:        %{name}-%{version}.tar
Summary:        litevirt controller initialize tools
Group:          Development/Tools
License:        LGPLv2+
URL:            https://github.com/litevirt
Buildarch: noarch

%description
This tool allows user to initlize the openstack controller.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/etc/template
mkdir -p $RPM_BUILD_ROOT/etc/template/db
cp db/*.sql $RPM_BUILD_ROOT/etc/template/db/
cp "export.sh" $RPM_BUILD_ROOT/etc/template/
cp "import.sh" $RPM_BUILD_ROOT/etc/template/

%files
%attr(0644,root,root) /etc/template/db/cinder.sql
%attr(0644,root,root) /etc/template/db/glance.sql
%attr(0644,root,root) /etc/template/db/heat.sql
%attr(0644,root,root) /etc/template/db/keystone.sql
%attr(0644,root,root) /etc/template/db/mysql.sql
%attr(0644,root,root) /etc/template/db/neutron.sql
%attr(0644,root,root) /etc/template/db/nova.sql
%attr(0644,root,root) /etc/template/export.sh
%attr(0644,root,root) /etc/template/import.sh

%changelog
* Thu May 22 2014 bohai <boh.ricky@gmail.com> - 0.1
- Update to upstream 0.1 release
