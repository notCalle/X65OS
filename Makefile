ROMSRC = _sysinit.a65	# MUST BE FIRST
ROMSRC += exec.a65
ROMSRC += romvec.a65

TARGETS += rom.srec
rom.srec: rom.bin
	bin2srec -o $@ -i $<

TARGETS += rom.bin
rom.bin: $(ROMSRC) rom.cfg include/version.i65
	cl65 -C rom.cfg -t none -o $@ $(ROMSRC)

_git_version = $(shell git describe --always)
TARGETS += include/version.i65
include/version.i65: include/version.tmp
	cmp -s $@ $< || mv $< $@

TARGETS += include/version.tmp
.PHONY: include/version.tmp
include/version.tmp: include/version.in
	@sed <$< >$@ s/__GIT_VERSION__/$(_git_version)/

.PHONY: clean
clean:
	rm -f $(TARGETS)
