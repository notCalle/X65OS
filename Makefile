LD65 = ld65 -m $(@:bin=map)
CA65 = ca65 -I include

#
# The ordering of sources matters for many reasons.
# Especially the SYSINIT and IRQCODE segments contain
# code that will run back-to-back in the order below
#
ROMSRC = src/_sysinit.a65	# MUST BE FIRST
ROMSRC += src/_systab.a65
ROMSRC += src/viab.a65
ROMSRC += src/memory.a65
ROMSRC += src/exec.a65
ROMSRC += src/task.a65		# MUST BE LAST w/ IRQCODE
ROMSRC += src/romvec.a65

ROMOBJ = $(ROMSRC:a65=o)
TARGETS += $(ROMOBJ)

.PHONY: depend
depend: depend.mk

.PHONE: all
all: $(TARGETS)

TARGETS += rom.srec
rom.srec: rom.bin
	bin2srec -o $@ -i $<

TARGETS += rom.bin
rom.bin: $(ROMOBJ) depend.mk rom.cfg
	$(LD65) -C rom.cfg -o $@ $(ROMOBJ)

TARGETS += rom.h
rom.h: rom.bin
	hexdump -v -e '16/1 "0x%02x," "\n"' $< >$@

TARGETS += include/version.i65
include/version.i65: include/version.tmp
	@cmp -s $@ $< || mv $< $@

_git_version = $(shell git describe --always)
TARGETS += include/version.tmp
.PHONY: include/version.tmp
include/version.tmp: include/version.in
	@sed <$< >$@ s/__GIT_VERSION__/$(_git_version)/

.PHONY: clean
clean:
	rm -f $(TARGETS)

TARGETS += depend.mk
depend.mk: $(ROMSRC:a65=mkdep)
	cat $< > $@

TARGETS += $(ROMSRC:a65=mkdep)
%.mkdep: %.a65
	$(CA65) --create-dep $@ $<

src/_sysinit.a65: include/version.i65

-include depend.mk
