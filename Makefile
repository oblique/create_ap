all:
	@echo "Run 'make install' for installation."

install:
	cp create_ap /usr/bin/create_ap
	[ ! -d /lib/systemd/system ] || cp create_ap.service /lib/systemd/system
