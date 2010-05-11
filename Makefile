# Makefile for the trEPR toolbox
# (c) 2007, Till Biskup <till.biskup@physik.fu-berlin.de>
# Created: 2007/02/02
#
# $Id$

# The version should not only be changed in this file but as well
# in the file trEPRtoolboxRevision in the MFILEDIR.
VERSION=0.2.0a

MFILEDIR=m-files
DOCDIR=doc
WEBDOCDIR=$(DOCDIR)/ROBODoc
MATLABDOCDIR=$(DOCDIR)/MATLAB-Help

TOOLBOXDIR=trEPR-$(VERSION)
TOOLBOXDOCDIR=$(TOOLBOXDIR)/documentation
TOOLBOXPRGDIR=$(TOOLBOXDIR)/trEPR
TOOLBOXEXADIR=$(TOOLBOXDIR)/examples

toolbox: tbdirs tbdoc
	cp -r $(MFILEDIR)/* $(TOOLBOXPRGDIR)/
	cp $(MFILEDIR)/info.xml $(TOOLBOXPRGDIR)/
	tar czf $(TOOLBOXDIR).tgz $(TOOLBOXDIR)
	zip -rq $(TOOLBOXDIR).zip $(TOOLBOXDIR)

tbdirs:
	@# creating directories for the toolbox, provided they do not exist
	@if [ ! -e $(TOOLBOXDIR) ]; then mkdir $(TOOLBOXDIR); else echo '(II) Toolbox dir exists, so not creating...'; fi
	@if [ ! -e $(TOOLBOXDOCDIR) ]; then mkdir $(TOOLBOXDOCDIR)/; fi
	@if [ ! -e $(TOOLBOXPRGDIR) ]; then mkdir $(TOOLBOXPRGDIR); fi
	@if [ ! -e $(TOOLBOXEXADIR) ]; then mkdir $(TOOLBOXEXADIR); fi

webdoc: $(DOCDIR) $(MFILEDIR)
	@echo '(II) Creating documentation for the web...'
	cd $(MFILEDIR); robodoc
	cd $(WEBDOCDIR); for i in *html; do ../postprocessing_robodoc $$i; done

tbdoc: $(DOCDIR) $(MFILEDIR)
	@echo '(II) Creating documentation for the toolbox...'
	cd $(MFILEDIR); robodoc
	cd $(WEBDOCDIR); rename s/_m//s *_m.html
	mv $(WEBDOCDIR)/*html $(TOOLBOXDOCDIR)
	cp -r $(MATLABDOCDIR)/* $(TOOLBOXDOCDIR)
