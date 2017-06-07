%{?systemd_requires}
# Upstream package name naturally contains an underscore
Name:           create_ap
Version:        0.4.6
Release:        1
Summary:        This script creates a NATed or Bridged WiFi Access Point

Group:          System Environment/Base
License:        BSD
Vendor:         oblique

Packager:       Robert Van Voorhees <rcvanvo@gmail.com>
Requires:       bash
Requires:       util-linux
Requires:       procps-ng
Requires:       hostapd
Requires:       iproute
Requires:       iw
Requires:       dnsmasq
Requires:       iptables
BuildRequires:  systemd

URL:            https://github.com/%{vendor}/%{name}
Source0:        https://github.com/%{vendor}/%{name}/archive/v%{version}.tar.gz
BuildArch:      noarch

%description
This script creates a NATed or Bridged WiFi Access Point.

%prep
%autosetup

%build
echo "Nothing to build"

%install
%make_install

%files
%config(noreplace) %{_sysconfdir}/create_ap.conf
%attr(0755, root, root) %{_bindir}/create_ap
%attr(0644, root, root) %{_unitdir}/create_ap.service
%attr(0644, root, root) %{_datarootdir}/bash-completion/completions/create_ap
%doc %{_datarootdir}/doc/create_ap/README.md

%post
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.service

%postun
%systemd_postun_with_restart %{name}.service

%changelog
* Mon May 1 2017 Robert Van Voorhees <rcvanvo@gmail.com> - 0.4.6-1
- Initial RPM release
