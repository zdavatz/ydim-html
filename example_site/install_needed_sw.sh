#!/bin/bash -v
set -e
export SRC_ROOT=/usr/local/src
export RUBY_19_VERSION=1.9.3-p547
export SUFFIX_19=`echo ${RUBY_19_VERSION} | awk '{gsub(/\./,"")}; 1'`
export RUBY_2_VERSION=2.3.1
export RUBY_2_SUFFIX=`echo ${RUBY_2_VERSION} | awk '{gsub(/\./,"")}; 1'`
export PATH=/usr/local/bin:/usr/bin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.4
export RUBY=/usr/local/bin/ruby${SUFFIX_19}

# Install Ruby 1.9.3 for Apache mod_ruby
function show_vars {
  if [ -f  $RUBY ]; then
    ls -l $RUBY
    $RUBY --version
  fi
  for item in RUBY SRC_ROOT RUBY_19_VERSION SUFFIX_19 PATH RUBY_2_VERSION RUBY_2_SUFFIX
  do
    echo "${item}=${!item}"
  done
}

function install_ruby_19 {
  if [ ! -d ${SRC_ROOT}/ruby-${RUBY_19_VERSION} ]
  then
    cd ${SRC_ROOT}
    pwd
    # rm -rf ruby-${RUBY_19_VERSION}
    if [ ! -f ruby-${RUBY_19_VERSION}.tar.gz ]
    then
      wget https://ftp.ruby-lang.org/pub/ruby/ruby-${RUBY_19_VERSION}.tar.gz
    fi
    tar -zxf ruby-${RUBY_19_VERSION}.tar.gz
  fi
  cd $SRC_ROOT/ruby-${RUBY_19_VERSION}
  if [ -f Makefile ]; then
    make  distclean
  fi
  # Adding --enable-shared leads to
  # apache2: Syntax error on line 155 of /etc/apache2/httpd.conf: Syntax error on line 3 of  \
  # /etc/apache2/modules.d/21_mod_ruby.conf: Cannot load /usr/lib64/apache2/modules/mod_ruby193-p547.so into server:
  # /usr/lib64/apache2/modules/mod_ruby193-p547.so: undefined symbol: ruby_dln_librefs
  ./configure --prefix=/usr/local --disable-install-doc --enable-shared --program-suffix=${SUFFIX_19} --libdir=/usr/local/lib 2>&1 | tee configure.log
  make -j9 2>&1 | tee make.log
  sudo make install 2>&1 | tee install.log
}

function install_ruby_2 {
  if [ ! -d ${SRC_ROOT}/ruby-${RUBY_2_VERSION} ]
  then
    cd ${SRC_ROOT}
    pwd
    if [ ! -f ruby-${RUBY_2_VERSION}.tar.gz ]
    then
      wget https://ftp.ruby-lang.org/pub/ruby/ruby-${RUBY_2_VERSION}.tar.gz
    fi
    ls -lrt
    tar -zxf ruby-${RUBY_2_VERSION}.tar.gz
  fi

  cd $SRC_ROOT/ruby-${RUBY_2_VERSION}
  if [ -f Makefile ]; then
    make  distclean
  fi
  ./configure --prefix=/usr/local --disable-install-doc --enable-shared --program-suffix=${RUBY_2_SUFFIX} --libdir=/usr/local/lib 2>&1 | tee configure.log
  make -j9 2>&1 | tee make.log
  sudo make install 2>&1 | tee install.log
}

function install_mod_ruby {
  # from http://dev.ywesee.com/Niklaus/20160413-ydim-html
  #  /usr/bin/ruby ./configure.rb --with-apr-includes=/usr/include/apr-1 --with-apxs=/usr/sbin/apxs I
  if [ ! -d ${SRC_ROOT}/mod_ruby ]
  then
    cd ${SRC_ROOT}
    git clone https://github.com/shugo/mod_ruby
  fi
  cd $SRC_ROOT/mod_ruby
  git pull
  if [ -f Makefile ]; then
    make  distclean
  fi
  # --with-apxs=/usr/sbin/apxs Build shared Apache module.
  # --with-apache Build static Apache module
  #
  $RUBY ./configure.rb \
    --with-apxs=/usr/sbin/apxs \
    --with-apr-includes=/usr/include/apr-1 \
    --prefix=/usr/local \
    --libdir=/usr/local/lib64 2>&1 | tee configure.log
  make 2>&1 | tee make.log
  sudo make install 2>&1 | tee install.log
  sudo cp -v mod_ruby.so /usr/lib64/apache2/modules/mod_ruby${SUFFIX_19}.so
}
function install_ydim_html_gems {
  sudo /usr/local/bin/gem${RUBY_2_SUFFIX} install ydim ydim-html
}
show_vars
install_ruby_19
install_mod_ruby
install_ruby_2
install_ydim_html_gems
show_vars
