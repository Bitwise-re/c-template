
#~ MAKEFILE SPECIAL TARGETS

#enables the makefile secondary expansion
.SECONDEXPANSION: ;
#disable implicit rules
.SUFFIXES: ;
#prevent make from deleting intermediates files
.SECONDARY: ;

#~ software
CC:=gcc

#~ architecture

#directories
SRCDIR:=./src
BINDIR:=./bin
SCRIPTDIR:=./scripts
BUILDDIR:=./build/other
ASSETDIR:=./build/assets/
ifeq ($(OS),Windows_NT)
	BUILDDIR:=./build/windows
else
	BUILDDIR:=./build/linux
endif

#extensions
HDREXT:=h
SRCEXT:=c
DEPEXT:=d
PPFEXT:=i
ASMEXT:=s
OBJEXT:=o
SLFEXT:=a
ifeq ($(OS),Windows_NT)
	DOTEXE:=.exe
	format_lib=$(1).dll
else
	DOTEXE:=
	format_lib=lib$(1).so
endif

#transform a library or executable file -$(1)- into the object files produced by this node, using a special formatting for each type of file -$(2)-
libexec-to-obj = $(patsubst %.c,%.o,$(wildcard $(SRCDIR)/$(patsubst $(2),%,$(notdir $(1)))/*.$(SRCEXT)))

#get all the header files included 
define getppfdep
$(shell cat $(patsubst %.$(PPFEXT),%.$(DEPEXT),$(1)) 2> /dev/null ||:)
endef

#create the produced files from a node, for each type of node
node-to-execs=$(foreach node,$(1),$(shell basename $(node))$(DOTEXE))
node-to-libs=$(foreach node,$(1),$(call format_lib,$(shell basename $(node))))
node-to-ofiles=$(foreach node,$(1),$(foreach file,$(shell $(MAKE) -C$(node) -qp 2> /dev/null | grep -w "__FILES :=" | grep -vw "node-to-ofiles" | cut -c12-),$(node)/$(file)))

#create the dependencies for and from an object file
obj-dep=$(filter-out $(2),$(foreach dfile,$(wildcard $(dir $(1))/*.$(DEPEXT)),$(foreach dep,$(shell cat $(dfile) 2>/dev/null ||:),$(filter $(EXECS),$(call node-to-execs, $(dir $(dep)))) $(filter $(LIBS),$(call node-to-libs, $(dir $(dep)))) $(filter $(OFILES),$(call node-to-ofiles, ./$(dir $(dep)))))))

#dependency formulas
EDEP = $(call obj-dep,$(call libexec-to-obj,$@,%$(DOTEXE)),$(notdir $@))
LDEP = $(call obj-dep,$(call libexec-to-obj,$@,$(call format_lib,%)),$(notdir $@))

#generates all the files to link against from EDEP or LDEP -$(1)-
link-deps = $(foreach file,$(foreach dep,$(filter $(LIBS),$(1)),$(call LINKLIB,$(dep))) $(foreach dep,$(filter-out $(LIBS) $(EXECS),$(1)),$(shell $(MAKE) -C$(dir $(dep)) -qp 2> /dev/null | grep -w "__IMPL_LINK :=" | grep -vw "link-deps" | cut -c15-)),$(BINDIR)/$(file))

#^ nodes
LNODES:=$(shell ./scripts/getnodes.sh -L $(SRCDIR) 2> /dev/null ||:)
ENODES:=$(shell ./scripts/getnodes.sh -E $(SRCDIR) 2> /dev/null ||:)
ONODES:=$(shell ./scripts/getnodes.sh -O $(SRCDIR) 2> /dev/null ||:)
ANODES:=$(LNODES) $(ENODES) $(ONODES)

EXECS:=$(call node-to-execs,$(ENODES))
LIBS:=$(call node-to-libs,$(LNODES))
OFILES:=$(call node-to-ofiles,$(ONODES))

#^flags
PPFLAGS:=-I$(SRCDIR) $(foreach node,$(ANODES),-I$(node))
CMPFLAGS:=-g -Wall -fPIC
ifeq ($(OS),Windows_NT)
	LFLAGS:=-Lbin -mwindows -Wl,-rpath='$${ORIGIN}'
else
	LFLAGS:=-Lbin -Wl,-rpath='$${ORIGIN}'
endif

ifeq ($(OS),Windows_NT)
	CREATEIMPLIB=-Wl,--out-implib,$@.$(SLFEXT)
endif

ifeq ($(OS),Windows_NT)
	LINKLIB=$(1).$(SLFEXT)
else
	LINKLIB=-l$(patsubst,$(call format_lib,%),%,$(1))
endif

ifeq ($(OS),Windows_NT)
	IMPLIBCLEANUP:=echo "removing build-purpose files..." && rm ./$(BUILDDIR)/$(call LINKLIB,$(call format_lib,*)) 2>/dev/null ||:
endif

Vdebug:
	@echo No debug recipe in vars.mk
