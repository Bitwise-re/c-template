
#~ MAKEFILE SPECIAL TARGETS

#enables the makefile secondary expansion
.SECONDEXPANSION: ;
#disable implicit rules
.SUFFIXES: ;
#prevent make from deleting intermediates files
.SECONDARY: ;

#~ CONSTANTS

#^ software
CC:=gcc

#^ architecture

#directories
SRCDIR:=./src
BINDIR:=./bin
SCRIPTDIR:=./scripts
BUILDDIR:=./build/other
ASSETDIR:=./build/assets/

#extensions
HDREXT:=h
SRCEXT:=c
DEPEXT:=d
PPFEXT:=i
ASMEXT:=s
OBJEXT:=o
#?DOTEXE:= 		in 'processed' section
#?format_lib= 	in 'processed' section

#~ FUNCTIONS

#transform a library or executable file -$(1)- into the object files produced by this node, using a special formatting for each type of file -$(2)-
libexec-to-obj = $(patsubst %.$(SRCEXT),%.$(OBJEXT),$(wildcard $(SRCDIR)/$(patsubst $(2),%,$(notdir $(1)))/*.$(SRCEXT)))

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

#~ PROCESSED VARIABLES/FUNCTIONS

#^ OS specific vars
UNAME_S:=Unknown
DOTEXE:=
format_lib=$(1)

ifeq ($(OS),Windows_NT)
	UNAME_S:=Windows
	DOTEXE:=.exe
	format_lib=$(1).dll
	BUILDDIR:=./build/windows
else
	UNAME_S:=$(shell uname -s 2> /dev/null ||:)
	format_lib=lib$(1).so
	BUILDDIR:=./build/linux
endif

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
LFLAGS:=-Lbin -Wl,-rpath='$${ORIGIN}'


Vdebug:
	@echo No debug recipe in vars.mk
