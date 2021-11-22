PROG := simpleqemu

DESTDIR ?=
PREFIX ?= ${DESTDIR}/usr/local
BINDIR ?= ${PREFIX}/bin

RM ?= rm -f

.PHONY: all install uninstall

all:
	@printf "This is a shell script, so there is nothing to do. Try \"make install\" instead.\n"

install:
	install -v main.sh ${BINDIR}/${PROG}

uninstall:
	${RM} ${BINDIR}/${PROG}
