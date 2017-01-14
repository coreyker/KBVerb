BUILDDIR=build
SOURCE=KBVerb.dsp
INCLUDES=primes.h
PD=$(BUILDDIR)/$(SOURCE:.dsp=~.pd_darwin)
SC=$(BUILDDIR)/$(SOURCE:.dsp=.scx)
AU=$(BUILDDIR)/$(SOURCE:.dsp=.component)
VST=$(BUILDDIR)/$(SOURCE:.dsp=.vst)
MAX=$(BUILDDIR)/$(SOURCE:.dsp=.~mxo)

all: $(PD) $(SC) $(PD) $(MAX) $(VST) $(AU)

$(PD) : $(SOURCE)	
	cd $(BUILDDIR) && cp ../$(SOURCE) ./ && cp ../$(INCLUDES) ./ && faust2puredata $(SOURCE)

$(SC) : $(SOURCE)
	cd $(BUILDDIR) && cp ../$(SOURCE) ./ && cp ../$(INCLUDES) ./ && faust2supercollider $(SOURCE)

$(MAX) : $(SOURCE)
	cd $(BUILDDIR) && cp ../$(SOURCE) ./ && cp ../$(INCLUDES) ./ && faust2max6 $(SOURCE)

$(VST) : $(SOURCE)
	cd $(BUILDDIR) && cp ../$(SOURCE) ./ && cp ../$(INCLUDES) /usr/local/include && faust2vst $(SOURCE)

$(AU) : $(SOURCE)
	cd $(BUILDDIR) && cp ../$(SOURCE) ./ && cp ../$(INCLUDES) ./ && faust2au $(SOURCE)

clean :
	rm -rf $(BUILDDIR)/*
