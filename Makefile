# $OpenBSD$

CLEANFILES=	bin-* stamp-*

.BEGIN:
	rm -f stamp-rotate

stamp-rotate:
	-${SUDO} mv -f /var/account/acct.2 /var/account/acct.3
	-${SUDO} mv -f /var/account/acct.1 /var/account/acct.2
	-${SUDO} mv -f /var/account/acct.0 /var/account/acct.1
	${SUDO} cp -f /var/account/acct /var/account/acct.0
	${SUDO} sa -sq
	${SUDO} accton /var/account/acct

TARGETS+=	fork
run-regress-fork:
	@echo '\n======== $@ ========'
	rm -f bin-fork
	cp /bin/sh bin-fork
	./bin-fork -c '( : ) & :'
	lastcomm | grep '^bin-fork * -F '
	lastcomm | grep '^bin-fork * - '

REGRESS_TARGETS=	${TARGETS:S/^/run-regress-/}
${REGRESS_TARGETS}:	stamp-rotate

.include <bsd.regress.mk>
