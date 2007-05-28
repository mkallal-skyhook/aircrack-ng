ROOT		= .
include		$(ROOT)/common.mak

SCRIPTS         = airmon-ng
DOCFILES        = ChangeLog INSTALLING README LICENSE AUTHORS VERSION


default: all

all:
	$(MAKE) -C src $(@)
	$(MAKE) -C test $(@)

install:
	$(MAKE) -C src $(@)
	$(MAKE) -C test $(@)
	install -m 755 $(SCRIPTS) $(sbindir)
	install -d $(mandir)
	install -m 644 ./manpages/* $(mandir)

uninstall:
	$(MAKE) -C src $(@)
	$(MAKE) -C test $(@)
	-rm -f $(sbindir)/airmon-ng
	-rm -f $(mandir)/aircrack-ng.1
	-rm -f $(mandir)/airdecap-ng.1
	-rm -f $(mandir)/aireplay-ng.1
	-rm -f $(mandir)/airmon-ng.1
	-rm -f $(mandir)/airodump-ng.1
	-rm -f $(mandir)/airtun-ng.1
	-rm -f $(mandir)/ivstools.1
	-rm -f $(mandir)/kstats.1
	-rm -f $(mandir)/makeivs.1
	-rm -f $(mandir)/packetforge-ng.1
	-rm -fr $(docdir)

strip: 
	$(MAKE) -C src $(@)
	$(MAKE) -C test $(@)

doc:
	install -d $(docdir)
	install -m 644 $(DOCFILES) $(destdir)$(docdir)

clean:
	$(MAKE) -C src $(@)
	$(MAKE) -C test $(@)

distclean: clean
