Name: yajl
Version: 2.1.1
Release: 0%{?dist}
Summary: Yet Another JSON Library (YAJL)

Group: Development/Libraries
License: BSD
URL: https://github.com/SteppeChange/yajl
Source0: %{name}-%{version}.tar.gz

BuildRequires: cmake

%package devel
Summary: Libraries, includes, etc to develop with YAJL
Requires: %{name} = %{version}-%{release}

%description
Yet Another JSON Library. YAJL is a small event-driven
(SAX-style) JSON parser written in ANSI C, and a small
validating JSON generator.

%description devel
Yet Another JSON Library. YAJL is a small event-driven
(SAX-style) JSON parser written in ANSI C, and a small
validating JSON generator.

This sub-package provides the libraries and includes
necessary for developing against the YAJL library

%prep
%setup -q -n %{name}-%{version}

%build
./configure
make

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%doc COPYING ChangeLog README TODO
/usr/local/bin/json_reformat
/usr/local/bin/json_verify
/usr/local/lib/libyajl.so
/usr/local/lib/libyajl.so.2
/usr/local/lib/libyajl.so.2.1.0

%files devel
%defattr(-,root,root,-)
%doc COPYING
%dir /usr/local/include/yajl
/usr/local/include/yajl/yajl_common.h
/usr/local/include/yajl/yajl_gen.h
/usr/local/include/yajl/yajl_parse.h
/usr/local/include/yajl/yajl_tree.h
/usr/local/include/yajl/yajl_version.h
/usr/local/lib/libyajl_s.a
/usr/local/share/pkgconfig/yajl.pc

%changelog
* Mon Sep 11 2017 AD <aleksei.dorofeev@steppechange.com>
  - Sync to 2.1.0
