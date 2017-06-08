# $OpenBSD$

# Start with a clean /var/account/acct accounting file and turn on
# process accounting with accton(8).  Each test executes a command
# with a unique name and checks the flags in the lastcomm(1) output.

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
	# Create shell program, fork a sub shell, and check the -F flag.
	cp -f /bin/sh bin-fork
	./bin-fork -c '( : ) & :'
	lastcomm bin-fork | grep -q ' -F '

TARGETS+=	su
run-regress-su:
	@echo '\n======== $@ ========'
	# Create true program, run as super user, and check the -S flag.
	cp -f /usr/bin/true bin-su
	${SUDO} ./bin-su
	lastcomm bin-su | grep -q ' -S '

TARGETS+=	core
run-regress-core:
	@echo '\n======== $@ ========'
	# Create shell program, abort sub shell, and check the -DX flag.
	cp -f /bin/sh bin-core
	ulimit -c unlimited; ./bin-core -c '( sleep 1 ) & kill -ABRT $$!'
	lastcomm bin-core | grep -q ' -FDX '

REGRESS_TARGETS=	${TARGETS:S/^/run-regress-/}
${REGRESS_TARGETS}:	stamp-rotate

.include <bsd.regress.mk>
