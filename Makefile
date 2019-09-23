.PHONY: default build test

-include local.mak

default: build

BINDING+=net.so

UNAME=$(shell uname)

include $(UNAME).mak

build: $(BINDING)

prefix=/usr

SODIR = $(DESTDIR)$(prefix)/lib/lua/5.1/

.PHONY: install
install: $(BINDING)
	mkdir -p $(SODIR)
	install -t $(SODIR) $(BINDING)

CWARNS = -Wall \
  -Wcast-align \
  -Wnested-externs \
  -Wpointer-arith \
  -Wshadow \
  -Wwrite-strings

DNETDEFS=$(shell dumbnet-config --cflags)
LNETDEFS=$(shell libnet-config --cflags --defines)
COPT=-O2 -DNDEBUG -g
CFLAGS=$(CWARNS) $(CDEFS) $(CLUA) $(LDFLAGS)
LDLIBS=$(LLUA)

LDDNET=$(shell dumbnet-config --libs)
LDLNET=$(shell libnet-config --libs)

CC.SO := $(CC) $(COPT) $(CFLAGS)

%.so: %.c
	$(CC.SO) -o $@ $^ $(LDLIBS)

net.so: net.c libnet_decode.c
net.so: LDLIBS+=$(LDDNET) $(LDLNET)
net.so: CDEFS=$(DNETDEFS) $(LNETDEFS)

TNET=$(wildcard test-*.lua)
TOUT=$(TNET:.lua=.test)

echo:
	echo $(TOUT)

test: net.test $(TOUT)

%.test: %.lua net.so
	lua5.1 $<
	touch $@

%.test: %-test %.so
	lua5.1 $<
	touch $@

%.test: %-test net.so
	lua5.1 $<
	touch $@

