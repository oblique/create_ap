all:
	@echo "Run 'make install' for installation."

install:
	cp create_ap /usr/bin/create_ap
	cp create_ap.service /lib/systemd/system/create_ap.service

