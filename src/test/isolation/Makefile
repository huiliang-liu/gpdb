#
# Makefile for isolation tests
#

subdir = src/test/isolation
top_builddir = ../../..
include $(top_builddir)/src/Makefile.global

# where to find psql for testing an existing installation
PSQLDIR = $(bindir)

override CPPFLAGS := -I$(srcdir) -I$(libpq_srcdir) -I$(srcdir)/../regress $(CPPFLAGS)

OBJS =  specparse.o isolationtester.o

all: isolationtester$(X) pg_isolation_regress$(X)

gpstringsubs.pl:
	rm -f $@ && $(LN_S) $(top_builddir)/src/test/regress/gpstringsubs.pl

gpdiff.pl: atmsort.pm explain.pm GPTest.pm
	rm -f $@ && $(LN_S) $(top_builddir)/src/test/regress/gpdiff.pl

GPTest.pm:
	rm -f $@ && $(LN_S) $(top_builddir)/src/test/regress/GPTest.pm

atmsort.pm:
	rm -f $@ && $(LN_S) $(top_builddir)/src/test/regress/atmsort.pm

explain.pm:
	rm -f $@ && $(LN_S) $(top_builddir)/src/test/regress/explain.pm

submake-regress:
	$(MAKE) -C $(top_builddir)/src/test/regress pg_regress.o

pg_regress.o: | submake-regress
	rm -f $@ && $(LN_S) $(top_builddir)/src/test/regress/pg_regress.o .

pg_isolation_regress$(X): isolation_main.o pg_regress.o
	$(CC) $(CFLAGS) $^ $(LDFLAGS) $(LDFLAGS_EX) $(LIBS) -o $@

isolationtester$(X): $(OBJS) | submake-libpq submake-libpgport
	$(CC) $(CFLAGS) $^ $(libpq_pgport) $(LDFLAGS) $(LDFLAGS_EX) $(LIBS) -o $@

distprep: specparse.c specscanner.c

# specscanner is compiled as part of specparse
specparse.o: specscanner.c

# specparse.c and specscanner.c are in the distribution tarball,
# so do not clean them here
clean distclean:
	rm -f isolationtester$(X) pg_isolation_regress$(X) $(OBJS) isolation_main.o
	rm -f pg_regress.o
	rm -f gpstringsubs.pl gpdiff.pl atmsort.pm explain.pm GPTest.pm
	rm -rf $(pg_regress_clean_files)

maintainer-clean: distclean
	rm -f specparse.c specscanner.c

# GPDB: pageinspect module is needed by some tests.
install-tests:
	$(MAKE) -C $(top_builddir)/contrib/pageinspect install

installcheck: all gpdiff.pl gpstringsubs.pl install-tests
	./pg_isolation_regress --psqldir='$(PSQLDIR)' $(EXTRA_REGRESS_OPTS) --inputdir=$(srcdir) --init-file=$(srcdir)/init_file --load-extension=pageinspect --schedule=$(srcdir)/isolation_schedule

check: all
	./pg_isolation_regress --temp-install=./tmp_check --inputdir=$(srcdir) --top-builddir=$(top_builddir) $(EXTRA_REGRESS_OPTS) --schedule=$(srcdir)/isolation_schedule

# Versions of the check tests that include the prepared_transactions test
# It only makes sense to run these if set up to use prepared transactions,
# via TEMP_CONFIG for the check case, or via the postgresql.conf for the
# installcheck case.
installcheck-prepared-txns: all
	./pg_isolation_regress --psqldir='$(PSQLDIR)' $(EXTRA_REGRESS_OPTS) --inputdir=$(srcdir) --schedule=$(srcdir)/isolation_schedule prepared-transactions

check-prepared-txns: all
	./pg_isolation_regress --temp-install=./tmp_check $(EXTRA_REGRESS_OPTS) --inputdir=$(srcdir) --top-builddir=$(top_builddir) --schedule=$(srcdir)/isolation_schedule prepared-transactions
