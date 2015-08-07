#!/bin/bash
make distclean
aclocal -I /usr/share/aclocal -I./config
autoheader
automake -a # --copy
autoconf
#./configure --with-matlab=/usr/local/MATLAB/R2013a
#make
