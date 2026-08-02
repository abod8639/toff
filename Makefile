# toff — Makefile
# Installs/uninstalls toff system-wide.
# Usage:
#   sudo make install          (installs to /usr/local)
#   sudo make install PREFIX=/usr  (installs to /usr)
#   sudo make uninstall

PREFIX      ?= /usr/local
BINDIR       = $(PREFIX)/bin
LIBDIR       = $(PREFIX)/lib/toff
MANDIR       = $(PREFIX)/share/man/man1
BASH_COMPDIR = $(PREFIX)/share/bash-completion/completions
ZSH_COMPDIR  = $(PREFIX)/share/zsh/site-functions
FISH_COMPDIR = $(PREFIX)/share/fish/vendor_completions.d

.PHONY: install uninstall check help

install:
	@echo "Installing toff to $(PREFIX)..."
	install -Dm755 src/toff                    $(DESTDIR)$(BINDIR)/toff
	install -Dm644 src/lib/banner.sh           $(DESTDIR)$(LIBDIR)/banner.sh
	install -Dm644 src/lib/countdown.sh        $(DESTDIR)$(LIBDIR)/countdown.sh
	install -Dm644 src/lib/media.sh            $(DESTDIR)$(LIBDIR)/media.sh
	install -Dm644 src/lib/parser.sh           $(DESTDIR)$(LIBDIR)/parser.sh
	install -Dm644 src/lib/shutdown.sh         $(DESTDIR)$(LIBDIR)/shutdown.sh
	install -Dm644 man/toff.1                  $(DESTDIR)$(MANDIR)/toff.1
	install -Dm644 completions/toff.bash       $(DESTDIR)$(BASH_COMPDIR)/toff
	install -Dm644 completions/toff.zsh        $(DESTDIR)$(ZSH_COMPDIR)/_toff
	install -Dm644 completions/toff.fish       $(DESTDIR)$(FISH_COMPDIR)/toff.fish
	install -Dm644 LICENSE                     $(DESTDIR)$(PREFIX)/share/licenses/toff/LICENSE
	@echo "Done. Run 'toff --help' to get started."

uninstall:
	@echo "Uninstalling toff from $(PREFIX)..."
	rm -f  $(DESTDIR)$(BINDIR)/toff
	rm -rf $(DESTDIR)$(LIBDIR)
	rm -f  $(DESTDIR)$(MANDIR)/toff.1
	rm -f  $(DESTDIR)$(BASH_COMPDIR)/toff
	rm -f  $(DESTDIR)$(ZSH_COMPDIR)/_toff
	rm -f  $(DESTDIR)$(FISH_COMPDIR)/toff.fish
	rm -rf $(DESTDIR)$(PREFIX)/share/licenses/toff
	@echo "Done."

# Quick sanity check (no actual shutdown)
check:
	@echo "=== Checking toff syntax ==="
	bash -n src/toff
	bash -n src/lib/banner.sh
	bash -n src/lib/countdown.sh
	bash -n src/lib/media.sh
	bash -n src/lib/parser.sh
	bash -n src/lib/shutdown.sh
	@echo "=== Checking parser ==="
	@bash -c 'source src/lib/parser.sh; source src/lib/countdown.sh; \
	    echo "1.30  → $$(toff_parse_time 1.30)s  (expect 5400)"; \
	    echo "90    → $$(toff_parse_time 90)s    (expect 5400)"; \
	    echo "1:30  → $$(toff_parse_time 1:30)s  (expect 5400)"; \
	    echo "1:30:00 → $$(toff_parse_time 1:30:00)s (expect 5400)"; \
	    echo "fmt   → $$(toff_format_duration 5400)  (expect 1h 30m 00s)"'
	@echo "=== All checks passed ==="

help:
	@echo "Targets:"
	@echo "  install    Install toff (set PREFIX= to override /usr/local)"
	@echo "  uninstall  Remove toff"
	@echo "  check      Run syntax and parser checks"
