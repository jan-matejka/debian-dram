prefix = /usr/local
bindir = $(prefix)/bin

TESTCMD ?= $$PWD/dram

.PHONY: all
all: dram dram.bin

.PHONY: check
check: all
	PATH=$$PWD:$$PATH $(TESTCMD) t

.PHONY: install
install: dram dram.bin
	install -m 755 dram $(DESTDIR)$(bindir)/dram
	install -s -m 755 dram.bin $(DESTDIR)$(bindir)/dram.bin

.PHONY: clean
clean:
	$(RM) dram dram.bin

dram: s/dram.sh
	install -m 755 $< $@

dram.bin: s/dram.d s/mdiff.d
	dub build
