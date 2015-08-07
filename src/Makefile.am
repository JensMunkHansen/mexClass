AUTOMAKE_OPTIONS = foreign 1.8 no-dependencies
VPATH = @srcdir@

INCLUDES = -I@top_srcdir@/include -I$(srcdir) -I$(MATLAB_DIR)/extern/include

bindir=$(exec_prefix)/bin

if WINNT
  MEXVSRC=$(MATLAB_DIR)/extern/include/mexversion.rc
  MEXVOBJ=$(top_builddir)/src/mexversionrc.o
  $(MEXVOBJ): $(MEXVSRC)
	windres -omexversionrc.o -O coff $(MEXVSRC)
endif

if ENABLE_CPP
  CPP_SRC = aperture_mex # aperture_mex apodization_mex line_mex image_mex sampled_image_mex
  TESTS = ApodizationTest InterpolateTest
endif

bin_PROGRAMS = $(CPP_SRC)
check_PROGRAMS = $(TESTS)

if ENABLE_CPP
  aperture_mex_SOURCES = aperture_mex.cpp aperture.cpp mexarg.c mm_malloc.cpp
  aperture_mex_CFLAGS  = -DNeed_mex_gateway $(MATLAB_FLAGS)
  aperture_mex_LDFLAGS = $(WRAPS) $(MATLAB_LINK) 			       
  aperture_mex_LDADD   = $(MATLAB_LIB)

#   bft3_mex_SOURCES = bft3_mex.cpp aperture_mex.cpp apodization_mex.cpp line_mex.cpp image_mex.cpp sampled_image_mex.cpp aperture.cpp apodization.cpp line.cpp image.cpp sampled_image.cpp sample_interpolate.cpp mexarg.c mm_malloc.cpp 
#   bft3_mex_CFLAGS  = $(MATLAB_FLAGS)	       
#   bft3_mex_LDFLAGS = $(WRAPS) $(MATLAB_LINK) 
#   bft3_mex_LDADD   = $(MATLAB_LIB)

endif
