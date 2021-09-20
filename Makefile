PROG := simpleqemu

PREFIX ?= /usr/local
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin

.PHONY: all install uninstall

all:
	@echo "This is a shell script, so there is nothing to do. Try \"make install\" instead."

install:
	@install -v main.sh $(DESTDIR)$(BINDIR)/$(PROG)

uninstall:
	@rm -vf $(DESTDIR)$(BINDIR)/$(PROG)
