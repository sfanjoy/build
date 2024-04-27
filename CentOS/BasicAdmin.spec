#
# Macros
#
%define APP_NAME        BasicAdmin
%define APP_VERSION     01
%define BRANCH_NAME     build/CentOS
#
# Pre-amble
#
Summary: Basic Setup and Admin scripts
Name:  %(echo %APP_NAME)
Version: %(echo %APP_VERSION)
Release: 1
Group: Admin Applications
License: MIT
Packager: Bigfoot
BuildRoot: %{_tmppath}/%{name}-%{version}
ExclusiveArch: x86_64
Requires: shadow-utils
#
%description
Basic Admin scripts for CentOS

%prep
# current dir is RPM_BUILD_DIR
rm -rf $RPM_BUILD_DIR/build
# clean up previous failed build
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT
git clone git@github.com:sfanjoy/build.git

%build
# current dir is RPM_BUILD_DIR
cd build/

%install
mkdir $RPM_BUILD_ROOT/root
mkdir $RPM_BUILD_ROOT/root/config
cp -r $RPM_BUILD_DIR/%BRANCH_NAME/bin $RPM_BUILD_ROOT/root
cp -r $RPM_BUILD_DIR/%BRANCH_NAME/etc $RPM_BUILD_ROOT/root/config
cp -r $RPM_BUILD_DIR/%BRANCH_NAME/home $RPM_BUILD_ROOT/root/config
#
%clean
rm -rf $RPM_BUILD_ROOT
rm -rf $RPM_BUILD_DIR/%BRANCH_NAME

%pre

%post
chmod 744 /root/bin/*

%postun

%files
%dir /root/bin
%dir /root/config
/root/bin/*
/root/config/*