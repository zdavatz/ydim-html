# ydim_html

* https://github.com/zdavatz/ydim-html.git

## DESCRIPTION:

ywesee Distributed Invoice Manager HTML Interface, Ruby

This is an application. Therefore it is not distributed as a gem, instead it has  Gemfile which specifies all dependencies.

## INSTALL:

* bundle install

## TEST:

Currently we have neither working unit tnor spec tests.

## Howto deploy a working site

1. Install apache2
2. Compile and install ruby-240. under /usr/local/ruby-2.4.0
3. Install yus (gem and initialize/load postgres database)
4. Install ydim (gem and initialize/load postgres database)
5. We use daemontools (run scripts under example_site/etc/services) to start, supervise and log yus, ydim and ydim-html
6. Create an id_rsa for ydim using sudo ssh-keygen -t dsa -f /etc/ydim/id_dsa
   We assume here that you entered 'xxx'.
   The id_rsa files must belong to the apache user. Therefore sudo chown -R apache /etc/ydim
7. Calling `ruby -e "require 'digest/md5'; p Digest::MD5::hexdigest(ARGV[0])" xxx` will return "f561aaf6ef0bf14d4208bb46a4ccb3ad"
8. Change the md5_pass to this value in /etc/ydim/ydim-htmld.yml
9. Adapt all values in /etc/ydim/*.yml to your needs
10. Configure apache for use with rack. See example_site/etc/apache
11. If you want to use a different port than 8050 for the rack service, adapt the run files, the apache conf and/or config.ru

    cd /var/www/your_site
    bundle-240 config build.pg --with-pg-config=/usr/local/pgsql-10.1/bin/pg_config
    bundle-240 install --path=vendor --without debugger


A bash script for step 2 and 13 is found under example_site/install_needed_sw.sh.

## DEVELOPERS:

* Masaomi Hatakeyama
* Zeno R.R. Davatz
* Hannes Wyss (up to Version 1.0)
* Niklaus Giger (ported to Ruby 2.4.0 and rack)

## LICENSE:

* GPLv2
