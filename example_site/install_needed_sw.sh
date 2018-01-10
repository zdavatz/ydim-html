#!/bin/bash -v
set -e
export SRC_ROOT=/usr/local/src
export PG_VERSION=10.1
export RUBY_VERSION=2.4.0
export RUBY_SUFFIX=`echo ${RUBY_VERSION} | awk '{gsub(/\./,"")}; 1'`
export PATH=/usr/local/bin:/usr/bin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.4
export RUBY=/usr/local/bin/ruby-${RUBY_SUFFIX}
export WWW_PATH=/var/www/ydim.ywesee.com/

# Install Ruby
function show_vars {
  if [ -f  $RUBY ]; then
    ls -l $RUBY
    $RUBY --version
  fi
  for item in RUBY SRC_ROOT PATH RUBY_VERSION RUBY_SUFFIX WWW_PATH
  do
    echo "${item}=${!item}"
  done
}

function install_ruby_2 {
  if [ ! -d ${SRC_ROOT}/ruby-${RUBY_VERSION} ]
  then
    cd ${SRC_ROOT}
    pwd
    if [ ! -f ruby-${RUBY_VERSION}.tar.gz ]
    then
      wget https://ftp.ruby-lang.org/pub/ruby/ruby-${RUBY_VERSION}.tar.gz
    fi
    ls -lrt
    tar -zxf ruby-${RUBY_VERSION}.tar.gz
  fi

  cd $SRC_ROOT/ruby-${RUBY_VERSION}
  if [ -f Makefile ]; then
    make  distclean
  fi
  ./configure --prefix=/usr/local --disable-install-doc --enable-shared --program-suffix=${RUBY_SUFFIX} --libdir=/usr/local/lib 2>&1 | tee configure.log
  make -j9 2>&1 | tee make.log
  sudo make install 2>&1 | tee install.log
}

function install_postgres_10 {
  cd /usr/local/src/
  git clone git://git.postgresql.org/git/postgresql.git
  cd postgresql
  git checkout REL_${PG_VERSION} -b ${PG_VERSION}
  mkdir build_dir
  cd build_dir
  ../configure
  make -j 8
  sudo make install
#  export LD_LIBRARY_PATH=/usr/local/pgsql/lib
#  export PATH=/usr/local/pgsql/bin:$PATH
#  psql --version
}
function install_ydim_html_gems {
  cd ${WWW_PATH}
  sudo -u apache bundle-${RUBY_VERSION} config build.pg --with-pg-config=/usr/local/pgsql-${PG_VERSION}/bin/pg_config
  sudo -u apache bundle-${RUBY_VERSION} install --path=vendor --without debugger  
}
show_vars
install_ruby_2
install_postgres_10
install_ydim_html_gems
show_vars
