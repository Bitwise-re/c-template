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
libexec-to-obj==$(patsubst %.$(SRCEXT),%.$(OBJEXT),$(wildcard $(SRCDIR)/$(patsubst $(BINDIR)/$(2),%,$(1))/*.$(SRCEXT)))


#get all the header files included 
define getppfdep
$(shell cat $(patsubst %.$(PPFEXT),%.$(DEPEXT),$(1)) 2> /dev/null ||:)
endef

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

EXECS:=$(foreach node,$(ENODES),$(shell basename $(node))$(DOTEXE))
LIBS:=$(foreach node,$(LNODES),$(call format_lib,$(shell basename $(node))))
OFILES:=$(foreach node,$(ONODES),$(shell $(MAKE) -C$(node) -qp 2> /dev/null | grep -w "FILES :=" | cut -c10-))


#^flags
CPPFLAGS:=-I$(SRCDIR) $(foreach node,$(ANODES),-I$(node))

#~ RECIPES
debug:
	@echo "execs : $(EXECS) | from nodes : $(ENODES)"
	@echo "libs : $(LIBS) | from nodes : $(LNODES)"
	@echo "others : $(OFILES) | from nodes : $(ONODES)"

all: $(OFILES) $(LIBS) $(EXECS)

build: reset all clean
	cp $(BINDIR)/* $(BUILDDIR)
	cp $(ASSETDIR)/* $(BUILDDIR)

reset:
	rm -fr ./bin/*
	rm -fr $(BUILDDIR)/*

clean:
	rm -f $(foreach node,$(ENODES) $(LNODES),$(node)/*.$(DEPEXT) $(node)/*.$(PPFEXT) $(node)/*.$(ASMEXT) $(node)/*.$(OBJEXT))
	$(foreach node,$(ONODES),$(MAKE) clean ;)

#make the files in the bin folder
$(EXECS) $(LIBS): %: $(BINDIR)/%

#^ executables linking
$(foreach exe,$(EXECS),$(BINDIR)/$(exe)): $$(call libexec-to-obj,$$@,%$(DOTEXE))
	# TODO : linking and get libraries to link against
	@echo "linking $^ into $@..."

#^ libraries linking
$(foreach lib,$(LIBS),$(BINDIR)/$(lib)): $$(call libexec-to-obj,$$@,$(call format_lib,%))
	# TODO : linking and get libraries to link against
	@echo "linking $^ into $@..."

#^ object files assembling
%.$(OBJEXT): %.$(ASMEXT)
	@echo "Assembling $< into $@"
	$(CC) $(ASMFLAGS) -c -o $@ $<

#assembly files compiling
%.$(ASMEXT): %.$(PPFEXT)
	@echo "Compiling $< into $@"
	$(CC) $(CMPFLAGS) -S -o $@ $<

#preprocessed file preprocessing (no kidding...)
%.$(PPFEXT): %.$(DEPEXT) $$(call getppfdep,$$@) # TODO : filter header files that can be processed
	@echo "Pre-processing $(filter-out $<,$^) into $@"
	$(CC) $(CPPFLAGS) -E -o $@ $(firstword $(shell cat $<))

#dependency file creation
%.$(DEPEXT): %.$(SRCEXT)
	@echo "Fetching dependencies for $<"
	$(CC) $(CPPFLAGS) -MM $< | sed -z 's/ \\\n//g' | cut -f 2 -d ':' | cut -c2- > $@

#catch-all rule for source and header files
%.$(SRCEXT) %.$(HDREXT): ;

#~ OTHERS

#*checks if all required scripts are present
ifeq (,$(wildcard $(SCRIPTDIR)/getnodes.sh))
$(error Required shell script not found in script directory ($(SCRIPTDIR)) : getnodes.sh)
endif