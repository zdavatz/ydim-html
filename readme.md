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
2. Compile and install ruby 1.9 and mod_ruby
3. Compile and install ruby >= 2.1.0 and ydim-html gem
4. Install yus (gem and initialize/load postgres database)
5. Install ydim (gem and initialize/load postgres database)
6. We use daemontools (run scripts under example_site/etc/services) to start, supervise and log yus, ydim and ydim-html
7. Create an id_rsa for ydim using sudo ssh-keygen -t dsa -f /etc/ydim/id_dsa
   We assume here that you entered 'xxx'.
   The id_rsa files must belong to the apache user. Therefore sudo chown -R apache /etc/ydim
8. Calling `ruby -e "require 'digest/md5'; p Digest::MD5::hexdigest(ARGV[0])" xxx` will return "f561aaf6ef0bf14d4208bb46a4ccb3ad"
9. Change the md5_pass to this value in /etc/ydim/ydim-htmld.yml
10. Adapt all values in /etc/ydim/*.yml to your needs
11. Configure apache for use with mod_ruby and ydim-html. See example_site/etc/apache

A bash script for steps 3 and 3 is found under example_site/install_needed_sw.sh.

## DEVELOPERS:

* Masaomi Hatakeyama
* Zeno R.R. Davatz
* Hannes Wyss (up to Version 1.0)
* Niklaus Giger (ported to Ruby 2.3.0)

## LICENSE:

* GPLv2
