ROMSRC = _sysinit.a65	# MUST BE FIRST
ROMSRC += _systab.a65
ROMSRC += memory.a65
ROMSRC += exec.a65
ROMSRC += task.a65
ROMSRC += romvec.a65

TARGETS += rom.srec
rom.srec: rom.bin
	bin2srec -o $@ -i $<

TARGETS += rom.bin
rom.bin: $(ROMSRC) rom.cfg include/version.i65
	cl65 -m rom.map -C rom.cfg -t none -o $@ $(ROMSRC)

TARGETS += rom.h
rom.h: rom.bin
	hexdump -v -e '16/1 "0x%02x," "\n"' $< >$@

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
