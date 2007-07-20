#
#  Makefile for rinse, the RPM installation entity
#
# Steve
# --
# $Id: Makefile,v 1.5 2007-07-20 11:24:42 steve Exp $
#


#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = ${TMP}
VERSION     = 0.3
BASE        = rinse
PREFIX      = 


#
#  Report on targets.
#
default:
	@echo " The following targets are available:"
	@echo " "
	@echo "  clean        - Remove editor backups"
	@echo "  install      - Install to ${PREFIX}"
	@echo "  test         - Run the tests"
	@echo "  test-verbose - Run the tests, verbosely"
	@echo "  uninstall    - Uninstall from ${PREFIX}"
	@echo " "


#
#  Clean edited files.
#
clean:
	@find . -name '*~' -delete
	@find . -name '.#*' -delete
	@find . -name 'build-stamp' -delete
	@find . -name 'configure-stamp' -delete
	@if [ -d debian/rinse ]; then rm -rf debian/rinse; fi



#
#  Make sure our scripts are executable.
#
fixupperms:
	for i in scripts/*/*.sh; do chmod 755 $$i; done


#
#  Install software
#
install: fixupperms
	mkdir -p ${PREFIX}/etc/bash_completion.d
	mkdir -p ${PREFIX}/etc/rinse
	mkdir -p ${PREFIX}/usr/bin
	mkdir -p ${PREFIX}/usr/lib/rinse
	mkdir -p ${PREFIX}/var/cache/rinse
	cp bin/rinse ${PREFIX}/usr/bin/
	chmod 755 ${PREFIX}/usr/bin/rinse
	cp etc/*.packages ${PREFIX}/etc/rinse
	cp etc/*.conf     ${PREFIX}/etc/rinse
	for i in scripts/*/; do name=`basename $$i`; if [ "$$name" != "CVS" ]; then mkdir -p /usr/lib/rinse/$$name  ; cp $$i/*.sh /usr/lib/rinse/$$name ; fi ; done
	cp misc/rinse ${PREFIX}/etc/bash_completion.d


#
#  Make a new release tarball, and make a GPG signature.
#
release: clean
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	find  $(DIST_PREFIX)/$(BASE)-$(VERSION) -name "CVS" -print | xargs rm -rf
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)/debian
	cd $(DIST_PREFIX) && tar --exclude=.cvsignore -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	gpg --armour --detach-sign $(BASE)-$(VERSION).tar.gz


#
#  Run the test suite.  (Minimal.)
#
test:
	prove --shuffle tests/


#
#  Run the test suite verbosely.  (Minimal.)
#
test-verbose:
	prove --shuffle --verbose tests/


#
#  Remove the software.
#
uninstall:
	rm -f  ${PREFIX}/usr/bin/rinse
	rm -f  ${PREFIX}/etc/rinse/*.conf
	rm -f  ${PREFIX}/etc/rinse/*.packages
	rm -rf ${PREFIX}/var/cache/rinse
	rm -rf ${PREFIX}/usr/lib/rinse
	rm -f  ${PREFIX}/etc/bash_completion.d/rinse

