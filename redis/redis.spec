Summary:        advanced key-value store
Name:           redis
Version:        6.0.15
Release:        1%{?dist}
License:        BSD
URL:            http://redis.io/
Group:          Applications/Databases
Vendor:         VMware, Inc.
Distribution:   Photon
Source0:        http://download.redis.io/releases/%{name}-%{version}.tar.gz
%define sha1 redis=432a1fd3b45ee2f35fa9f9db57514b490b8c4724
Patch0:         redis-conf.patch
BuildRequires:  gcc
BuildRequires:  systemd
BuildRequires:  make
BuildRequires:  which
BuildRequires:  tcl
BuildRequires:  tcl-devel
BuildRequires:  procps-ng
Requires:       systemd
Requires(pre):  /usr/sbin/useradd /usr/sbin/groupadd

%description
Redis is an in-memory data structure store, used as database, cache and message broker.

%prep
%autosetup -p1

%build
grep -F 'cd jemalloc && ./configure ' ./deps/Makefile
sed -ri 's!cd jemalloc && ./configure !&'"--with-lg-page=16 --with-lg-hugepage=21"' !' ./deps/Makefile
grep -F "cd jemalloc && ./configure --with-lg-page=16 --with-lg-hugepage=21 " ./deps/Makefile;
make %{?_smp_mflags}

%install
install -vdm 755 %{buildroot}
make PREFIX=%{buildroot}/usr install %{?_smp_mflags}
install -D -m 0640 %{name}.conf %{buildroot}%{_sysconfdir}/%{name}.conf
mkdir -p %{buildroot}/var/lib/redis
mkdir -p %{buildroot}/var/log
mkdir -p %{buildroot}/var/opt/%{name}/log
ln -sfv /var/opt/%{name}/log %{buildroot}/var/log/%{name}
mkdir -p %{buildroot}/usr/lib/systemd/system
cat << EOF >>  %{buildroot}/usr/lib/systemd/system/redis.service
[Unit]
Description=Redis in-memory key-value database
After=network.target

[Service]
ExecStart=/usr/bin/redis-server /etc/redis.conf --daemonize no
ExecStop=/usr/bin/redis-cli shutdown
User=redis
Group=redis

[Install]
WantedBy=multi-user.target
EOF

%check
#make check %{?_smp_mflags}

%pre
getent group %{name} &> /dev/null || \
groupadd -r %{name} &> /dev/null
getent passwd %{name} &> /dev/null || \
useradd -r -g %{name} -d %{_sharedstatedir}/%{name} -s /sbin/nologin \
-c 'Redis Database Server' %{name} &> /dev/null
exit 0

%post
/sbin/ldconfig
%systemd_post  redis.service

%postun
/sbin/ldconfig
%systemd_postun_with_restart redis.service

%files
%defattr(-,root,root)
%dir %attr(0750, redis, redis) /var/lib/redis
%dir %attr(0750, redis, redis) /var/opt/%{name}/log
%attr(0750, redis, redis) %{_var}/log/%{name}
%{_bindir}/*
%{_libdir}/systemd/*
%config(noreplace) %attr(0640, %{name}, %{name}) %{_sysconfdir}/redis.conf

%changelog
*   Yan Wang <wangyan@vmware.com>
-   Customize redis from original spec
