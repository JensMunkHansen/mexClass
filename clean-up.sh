#!/bin/bash
make clean
rm -f ./Debug/*
rm -f ./Release/*
rm -f ./Debug-pthreads/*
rm -f ./x64/Debug/*
rm -f ./x64/Release/*
rm -f *.ncb
rm -f *.suo
rm -Rf Makefile.in ./src/Makefile.in aclocal.m4 ./autom4te.cache
rm -f configure
rm -f Makefile
rm -f ./src/Makefile
rm -f config.log config.status
rm -f ./include/config.h.in
rm -f ./include/config.h
rm -f ./include/stamp-h1
rm -Rf ./doc/html/*
rm -Rf ./doc/latex/*
rm -f ./doxygen/*.png
rm -f ./doxygen/*.eps
rm -f ./doxygen/*.pdf
find . -name \*~ | xargs -i -t rm -f {}
rm -f figures/figtex2eps-preamble.tex
