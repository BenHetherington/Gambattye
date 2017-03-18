.SUFFIXES: .c .cpp .o

CC ?= cc
CXX ?= c++
AR ?= ar
RANLIB ?= ranlib
PKG_CONFIG = pkg-config

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share
DOCDIR = $(SHAREDIR)/doc/gambatte
INSTALL = install
INSTALL_DIR = $(INSTALL) -d
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

LIB = libgambatte/libgambatte.a
TEST = test/testrunner

PYTHON ?= python

LIB_OBJECTS = \
	libgambatte/src/bitmap_font.o \
	libgambatte/src/cpu.o \
	libgambatte/src/gambatte.o \
	libgambatte/src/initstate.o \
	libgambatte/src/interrupter.o \
	libgambatte/src/interruptrequester.o \
	libgambatte/src/loadres.o \
	libgambatte/src/memory.o \
	libgambatte/src/sound.o \
	libgambatte/src/state_osd_elements.o \
	libgambatte/src/statesaver.o \
	libgambatte/src/tima.o \
	libgambatte/src/file/file.o \
	libgambatte/src/mem/cartridge.o \
	libgambatte/src/mem/memptrs.o \
	libgambatte/src/mem/pakinfo.o \
	libgambatte/src/mem/rtc.o \
	libgambatte/src/sound/channel1.o \
	libgambatte/src/sound/channel2.o \
	libgambatte/src/sound/channel3.o \
	libgambatte/src/sound/channel4.o \
	libgambatte/src/sound/duty_unit.o \
	libgambatte/src/sound/envelope_unit.o \
	libgambatte/src/sound/length_counter.o \
	libgambatte/src/video.o \
	libgambatte/src/video/ly_counter.o \
	libgambatte/src/video/lyc_irq.o \
	libgambatte/src/video/next_m0_time.o \
	libgambatte/src/video/ppu.o \
	libgambatte/src/video/sprite_mapper.o

TEST_OBJECTS = \
	test/testrunner.o
	
libgambatte: $(LIB)

ZLIB_LFLAGS != $(PKG_CONFIG) --libs zlib

$(LIB): $(LIB_OBJECTS)
	$(AR) $(ARFLAGS) $@ $(LIB_OBJECTS)
	$(RANLIB) $@

PKGCONFIG_CFLAGS != $(PKG_CONFIG) --cflags sdl libpng zlib
.c.o:
	$(CC) $(CFLAGS) -c $< -o $*.o
.cpp.o:
	$(CXX) -Ilibgambatte/src -Ilibgambatte/include \
		-Icommon $(CXXFLAGS) -c $< -o $*.o \
		-DHAVE_STDINT_H \
		$(PKGCONFIG_CFLAGS)

TEST_GBS = \
		test/hwtests/*.gb* \
		test/hwtests/*/*.gb* \
		test/hwtests/*/*/*.gb* \
		test/hwtests/*/*/*/*.gb*

test: $(TEST)
	$(PYTHON) test/qdgbas.py \
		test/hwtests/*.asm \
		test/hwtests/*/*.asm \
		test/hwtests/*/*/*.asm \
		test/hwtests/*/*/*/*.asm
	$(TEST) $(TEST_GBS)

PNG_LFLAGS != $(PKG_CONFIG) --libs libpng
$(TEST): $(TEST_OBJECTS) $(LIB)
	$(CXX) $(CXXFLAGS) -o $@ $(TEST_OBJECTS) $(LIB) \
		$(PNG_LFLAGS) $(ZLIB_LFLAGS)

clean:
	rm -f $(TEST) $(TEST_OBJECTS) $(TEST_GBS)
	rm -f $(LIB) $(LIB_OBJECTS)


.PHONY: clean
