UNAME := $(shell uname -a)
OCCTINCLUDE := $(shell if test -d /usr/local/include/opencascade; then echo "/usr/local/include/opencascade"; else echo ""; fi)

OCCLIBS= \
-lTKXCAF -lTKXDESTEP -lTKCDF -lTKRWMesh \
-lTKBRep -lTKG2d -lTKG3d -lTKGeomBase \
-lTKMath -lTKMesh -lTKSTEP -lTKSTEP209 \
-lTKSTEPAttr -lTKSTEPBase -lTKSTL -lTKXSBase -lTKernel \

ifeq "$(OCCTINCLUDE)" ""

OPENCASCADEINC ?= /usr/include/opencascade
OPENCASCADELIB ?= /usr/lib/opencas

$(info Using OPENCASCADEINC as "${OPENCASCADEINC}")
$(info Using OPENCASCADELIB as "${OPENCASCADELIB}")

CXXFLAGS += -I$(OPENCASCADEINC)
LDFLAGS += -L$(OPENCASCADELIB) -L/usr/lib ${OCCLIBS}

else

CXXFLAGS += -I/usr/local/include/opencascade -I/usr/include
LDFLAGS += -L/usr/local/lib -L/usr/lib ${OCCLIBS}

endif


ifeq (Darwin,$(findstring Darwin,$(UNAME)))
CXX=clang++ -std=c++11 -stdlib=libc++
else
CXX=g++
endif

#---------------------------------------------------------------------
#targets
#---------------------------------------------------------------------

ifeq "$(MAKECMDGOALS)" ""
 CXXFLAGS += -ggdb3
endif
ifeq "$(MAKECMDGOALS)" "profile"
 CXXFLAGS += -pg -ggdb3
 LDFLAGS += -pg
endif

# Determine where we should output the object files.
OUTDIR = debug
ifeq "$(MAKECMDGOALS)" "debug"
 OUTDIR = debug
 CXXFLAGS += -ggdb3
endif
ifeq "$(MAKECMDGOALS)" "release"
 OUTDIR = release
 CXXFLAGS += -O3
endif
ifeq "$(MAKECMDGOALS)" "profile"
 OUTDIR = profile
endif

# Add .d to Make's recognized suffixes.
SUFFIXES += .d

# We don't need to clean up when we're making these targets
NODEPS:=clean

#Find all the C++ files in the src/ directory
#SOURCES:=$(shell find * -name '*.cpp' | sort)
SOURCES:=$(shell ls *.cpp | sort)
OBJS:=$(patsubst %.cpp,%.o,$(SOURCES))

#These are the dependency files, which make will clean up after it creates them
DEPFILES:=$(patsubst %.cpp,%.d,$(SOURCES))

#Don't create dependencies when we're cleaning, for instance
ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
    -include $(DEPFILES)
endif

EXE = step2gltf

all:	$(EXE)

debug:	$(EXE)

release:$(EXE)

profile:$(EXE)

$(EXE): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(OBJS)

#This is the rule for creating the dependency files
deps/%.d: %.cpp
	$(CXX) $(CXXFLAGS) -MM -MT '$(patsubst src/%,obj/%,$(patsubst %.cpp,%.o,$<))' $< > $@

#This rule does the compilation
obj/%.o: %.cpp %.d %.h
	@$(MKDIR) $(dir $@)
	$(CXX) $(CXXFLAGS) -o $@ -c $<

# make clean && svn update
clean:
	bash -c 'rm -f *.o $(OBJS) $(EXE)'

install:
	install -m 0755 $(EXE) /usr/local/bin/$(EXE)

uninstall:
	rm -f /usr/local/bin/$(EXE)
