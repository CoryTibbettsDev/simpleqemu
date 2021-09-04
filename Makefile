PROGRAM_NAME := simpleqemu

PREFIX ?= /usr/local
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man

.PHONY: all install uninstall

all:
	@echo "This is a shell script, so there is nothing to do. Try \"make install\" instead."

install:
	@install -v main.sh $(DESTDIR)$(BINDIR)/$(PROGRAM_NAME)

uninstall:
	@rm -vf "$(DESTDIR)$(BINDIR)/$(PROGRAM_NAME)"
