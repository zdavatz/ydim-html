# ydim_html

* https://github.com/zdavatz/ydim-html.git

## DESCRIPTION:

ywesee Distributed Invoice Manager HTML Interface, Ruby

This is an application. Therefore it is not distributed as a gem, instead it has a Gemfile which specifies all dependencies.

It stores no data of its own: all debitors, invoices and auto-invoices live in a
separate `ydimd` DRb server (the `ydim` gem, backed by PostgreSQL via ODBA).
This process is the HTML/AJAX front-end in front of that service.

## INSTALL:

* bundle install

## CONFIGURATION:

Configuration is read by RCLConf from `/etc/ydim/ydim-htmld.yml` (see
`lib/ydim/html/config.rb` for the full list of keys and their defaults). Any key
may also be overridden on the command line as `key=value`.

The application will not start unless

* `email`, `md5_pass` and `root_key` are set (they default to `nil`),
* the DSA private key named by `root_key` is readable, and
* a `ydimd` server answers at `server_url` (default `druby://127.0.0.1:12375`).

## RUN:

    bundle exec rackup -p 8050

Pass the port explicitly. `config.ru` used to pin it with a `#\ -p 8050` magic
comment, which was dropped when the app moved to rackup 1.0; a bare `rackup`
now listens on 9292, while the example Apache configuration proxies to
`localhost:8050`.

## TEST:

There are currently no working unit or spec tests, and none run in CI
(`.github/workflows/codeql.yml` analyses JavaScript only).

`spec/` still refers to `YDIM::Html::Util::Server`, a class removed during the
rack port, and drives a real browser through watir against a WEBrick stub built
on the pre-rack SBSM request API. `test/` holds older Selenium RC tests that are
not wired up either. Both are kept for reference; verify changes by running the
application.

## AUTO-INVOICE REMINDERS:

In an auto-invoice ("Vorlage"), a reminder body containing an
`<invoice></invoice>` block has that block replaced on save with a plain-text
table of the current items (quantity, text, currency, amount) and the net
total. Items without text render as empty lines.

## Howto deploy a working site

1. Install apache2
2. Compile and install ruby-320 under /usr/local (the daemontools run scripts in
   `example_site/service` call `/usr/local/bin/ruby-320` and
   `/usr/local/bin/bundle-320`)
3. Install yus (gem and initialize/load postgres database)
4. Install ydim (gem and initialize/load postgres database)
5. We use daemontools (run scripts under example_site/service) to start, supervise and log yus, ydim and ydim-html
6. Create a DSA key for ydim using sudo ssh-keygen -t dsa -f /etc/ydim/id_dsa
   We assume here that you entered 'xxx'.
   The key files must belong to the apache user. Therefore sudo chown -R apache /etc/ydim
7. Calling `ruby -e "require 'digest/md5'; p Digest::MD5::hexdigest(ARGV[0])" xxx` will return "f561aaf6ef0bf14d4208bb46a4ccb3ad"
8. Change the md5_pass to this value in /etc/ydim/ydim-htmld.yml
9. Adapt all values in /etc/ydim/*.yml to your needs
10. Configure apache for use with rack. See example_site/etc/apache
11. If you want to use a different port than 8050 for the rack service, adapt the run files and the apache conf
12. Install the gems into the site:

        cd /var/www/your_site
        bundle-320 config build.pg --with-pg-config=/usr/local/pgsql-10.1/bin/pg_config
        bundle-320 install --path=vendor --without debugger

A bash script covering steps 2 and 12 is found under
`example_site/install_needed_sw.sh`. Note that it still pins Ruby 2.4.0 and
PostgreSQL 10.1 — adapt `RUBY_VERSION` before using it.

## DEVELOPERS:

* Masaomi Hatakeyama
* Zeno R.R. Davatz
* Hannes Wyss (up to Version 1.0)
* Niklaus Giger (ported to Ruby 2.4.0 and rack)

See `CLAUDE.md` for an architecture overview (SBSM state machine, HtmlGrid
views, the DRb boundary and the two allow-lists that silently drop unregistered
events and form fields).

## LICENSE:

* GPLv2
