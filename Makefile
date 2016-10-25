PREFIX=/usr
MANDIR=$(PREFIX)/share/man
BINDIR=$(PREFIX)/bin

all:
	@echo "Run 'make install' for installation."
	@echo "Run 'make uninstall' for uninstallation."

install:
	install -Dm755 create_ap $(DESTDIR)$(BINDIR)/create_ap
	install -Dm644 create_ap.conf $(DESTDIR)/etc/create_ap.conf
	[ ! -d /lib/systemd/system ] || install -Dm644 create_ap.service $(DESTDIR)/lib/systemd/system/create_ap.service
	install -Dm644 bash_completion $(DESTDIR)$(PREFIX)/share/bash-completion/completions/create_ap
	install -Dm644 README.md $(DESTDIR)$(PREFIX)/share/doc/${pkgname}/README.md

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/create_ap
	rm -f $(DESTDIR)/etc/create_ap.conf
	[ ! -f /lib/systemd/system/create_ap.service ] || rm -f $(DESTDIR)/lib/systemd/system/create_ap.service
	rm -f $(DESTDIR)$(PREFIX)/share/bash-completion/completions/create_ap
	rm -f $(DESTDIR)$(PREFIX)/share/doc/${pkgname}/README.md
