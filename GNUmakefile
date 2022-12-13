prefix = /usr/local
bindir = $(prefix)/bin
mandir = $(prefix)/share/man
man1dir = $(mandir)/man1
man5dir = $(mandir)/man1

TESTCMD ?= $$PWD/dram

.PHONY: all
all: dram dram.bin

.PHONY: check
check: all
	PATH=$$PWD:$$PATH $(TESTCMD) -e TESTROOT=$$PWD/t t

.PHONY: install
install: dram dram.bin | installdirs
	install -m 755 dram $(DESTDIR)$(bindir)/dram
	install -s -m 755 dram.bin $(DESTDIR)$(bindir)/dram.bin
	install -m 644 m/dram.1.in $(DESTDIR)$(man1dir)/dram.1
	install -m 644 m/dram.5.in $(DESTDIR)$(man5dir)/dram.5

.PHONY: installdirs
installdirs:
	install -m 755 -d $(DESTDIR)$(bindir)
	install -m 755 -d $(DESTDIR)$(man1dir)
	install -m 755 -d $(DESTDIR)$(man5dir)

.PHONY: clean
clean:
	$(RM) dram dram.bin

dram: s/dram.sh
	install -m 755 $< $@

dram.bin: s/dram.d s/mdiff.d
	dub build
