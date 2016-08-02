all:
	@echo "Run 'make install' for installation."
	@echo "Run 'make uninstall' for uninstallation."

install:
	cp create_ap /usr/bin/create_ap
	cp create_ap.conf /etc/create_ap.conf
	[ ! -d /lib/systemd/system ] || cp create_ap.service /lib/systemd/system
	mkdir -p /usr/share/bash-completion/completions
	cp bash_completion /usr/share/bash-completion/completions/create_ap

uninstall:
	rm /usr/bin/create_ap
	rm /etc/create_ap.conf
	[ ! -f /lib/systemd/system/create_ap.service ] || rm /lib/systemd/system/create_ap.service
	rm /usr/share/bash-completion/completions/create_ap
