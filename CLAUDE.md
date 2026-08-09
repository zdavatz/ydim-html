# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`ydim-html` is the web front-end for YDIM (ywesee Distributed Invoice Manager). It is an **application, not a gem** — dependencies are pinned in `Gemfile.lock` and it is deployed by checking out the repo, not by `gem install`.

It owns **no data**. All models (debitors, invoices, auto-invoices, items) live in a separate `ydimd` DRb server (the `ydim` gem, backed by PostgreSQL via ODBA). This process is a thin stateful HTML/AJAX layer in front of that DRb service.

## Commands

```bash
bundle install                    # deps (needs pg headers; see readme.md for --with-pg-config)
bundle exec rackup -p 8050        # run the web app — see "Running locally" caveats below
bundle exec rspec                 # spec suite (currently broken, see below)
bundle exec rake spec             # same, via Rakefile (cleans pkg/*.gem first)
bundle exec rspec spec/smoketest_spec.rb -e "should allow to log in"   # single example
```

**Tests do not currently run.** `spec/spec_helper.rb` references `YDIM::Html::Util::Server`, a class removed during the rack port, and drives a real Firefox via watir against a WEBrick stub built on the pre-rack `SBSM::Request`/`SBSM::Apache` API. `readme.md` states this plainly; the specs were deliberately removed from CI in commit `cdc49ac`. `test/` holds even older Selenium RC tests (`test/selenium.rb` is a vendored 2006 Selenium driver) that are not wired to anything. Do not assume a green suite exists — verify changes by running the app.

CI is **only** `.github/workflows/codeql.yml`, and it analyses `javascript` only. No Ruby job runs on push.

## Running locally

The app refuses to boot without external state. `YDIM::Html::Util::App#initialize` (`lib/ydim/html/util/rack_app.rb`) will raise unless:

- `/etc/ydim/ydim-htmld.yml` exists and supplies `email`, `md5_pass` and `root_key` (defaults for these are `nil`),
- the DSA private key at `root_key` is readable,
- a `ydimd` DRb server is reachable at `server_url` (default `druby://127.0.0.1:12375`).

Config keys can also be overridden as `key=value` on the command line — `RCLConf` parses `ARGV` (`lib/ydim/html/config.rb`).

Port: `config.ru` used to pin 8050 via a `#\ -p 8050` magic comment, removed in `d775bc6` when rackup 1.0 dropped support for it. Pass `-p 8050` explicitly; bare `rackup` binds 9292 and the Apache reverse proxy in `example_site` (which targets `localhost:8050`) will not reach it.

`App#initialize` shells out to `git rev-parse HEAD` for the version banner, so it expects to run from a git checkout.

## Architecture

SBSM (a stateful, session-and-state-machine web framework) + HtmlGrid (a grid-coordinate HTML builder). Neither is a mainstream framework — read the state/view constants below rather than pattern-matching from Rails.

Request path:

```
config.ru → Util::RackInterface (SBSM::RackInterface)
          → Util::Session (SBSM::Session, one per cookie 'oddb.org')
          → State object (VIEW constant) → HtmlGrid view → HTML
```

### States (`lib/ydim/html/state/`)

Each state subclasses `SBSM::State`, declares `VIEW = <a view class>`, and exposes **public methods named after events**. SBSM dispatches the request's `event` parameter to the method of that name; the returned object becomes the session's next state (`return self` to stay put).

- `Global` (`state/global.rb`) is the base for every logged-in state and defines the shared events: `debitor`, `invoice`, `pdf`, `logout`, `send_invoice`, `create_debitor`, `create_invoice`, `create_autoinvoice`. Its `EVENT_MAP` routes `:debitors`/`:invoices` to their state classes.
- `state/global_predefine.rb` exists only to declare an empty `Global` so sibling files can subclass it without a require cycle. Requiring `global.rb` instead from a state file will deadlock the load order.
- `VOLATILE = true` marks an AJAX-fragment state: it renders and is discarded, leaving the persistent state untouched. All `Ajax*` classes use it.
- `Global::Stub` is a carrier object standing in for a not-yet-created invoice, so the same view can render before and after persistence.
- `AutoInvoice` (recurring-invoice templates, "Vorlagen" in the UI) subclasses `Invoice` and swaps `invoice_key` from `:invoice` to `:autoinvoice` via the `AutoInvoiceKeys` mixin — that single symbol switches every remote call to the auto-invoice variant.

### Views (`lib/ydim/html/view/`)

HtmlGrid composites laid out by `COMPONENTS = { [col,row] => :method_or_symbol }`. Common constants: `CONTENT` (page body inside `Template`), `DEFAULT_CLASS`, `SYMBOL_MAP` (per-key widget class), `LABELS`, `CSS_MAP`, `COMPONENT_CSS_MAP`, `EVENT` (form submit event).

`view/htmlgrid.rb` **monkeypatches HtmlGrid globally** — it reopens `HtmlGrid::Component`, `Composite`, `Form`, `InputText`, `List` and `Pass`. It adds the class macros used all over the views:

- `escaped(*names)` — define escaped, number-formatted accessors
- `links(event, *names)` — define accessors rendering a link to `event` with `unique_id`
- `List.ajax_inputs(*keys)` — define `key[index]` text inputs wired to the `ajax_item` event
- thousands separators (`1'234`) and `precision` pulled from `@session.state.model`

`view/template.rb` is the page shell and injects the two `<script>` tags (`dojo.js`, `ydim.js`).

### Session and the DRb boundary

`Util::Session#method_missing` (`lib/ydim/html/util/session.rb`) forwards **any** unknown call to the `ydimd` DRb server, opening a fresh `YDIM::Client` login with the DSA key and logging out in an `ensure`. So `@session.debitors`, `@session.invoice(id)`, `@session.generate_invoice(id)` etc. are remote calls that each cost a full login/logout round trip — be aware when adding calls inside loops or per-row view methods.

Models returned across DRb are ODBA objects; persist mutations with `model.odba_store` (see `State::Debitor#update_model`, `State::Invoice#_do_update`).

Authentication is a single hard-coded admin: `App#login` compares the submitted email and MD5 password hash against `config.email` / `config.md5_pass`. Despite `readme.md` mentioning yus, this app does not talk to yus.

### AJAX

Client side is `doc/resources/javascript/ydim.js` on a vendored 2006-era Dojo (`doc/resources/javascript/dojo.js`). Three entry points: `reload_form`, `reload_list`, `reload_data` — the first two replace `innerHTML` with a server-rendered fragment; `reload_data` evaluates a `var ajaxResponse = {...}` object emitted by `View::AjaxValues` and patches individual fields in place. `sbsm_encode` double-encodes values (an encoding workaround, not redundant).

Server side, each `ajax_*` event returns a `VOLATILE` state whose `VIEW` is a *sub-component* of the page rather than a full `Template`.

## Two things that silently swallow changes

1. **`Util::Validator` (`lib/ydim/html/util/validator.rb`) is an allow-list.** A new event is ignored unless added to `EVENTS`; a new form field is dropped unless added to `STRINGS`, `NUMERIC`, `BOOLEAN`, `DATES`, `ENUMS` or `HTML`. Symptom: the form posts, no error appears, the value is simply absent.

2. **`Custom::Lookandfeel` (`lib/ydim/html/util/lookandfeel.rb`) holds every user-visible string**, German only (`DICTIONARIES['de']`). A label with no entry renders as its raw symbol. List column headers use the `th_<key>` convention; multi-part messages are numbered (`:confirm_send_invoice0` / `1`, `:e_missing0` / `1`) and joined by `lookup` with the interpolated value between them.

## Legacy files — do not treat as live code

- `etc/config.rb` and `doc/index.rbx` — the pre-rack CGI entry point and its separate config. Superseded by `config.ru` + `lib/ydim/html/config.rb`.
- `etc/trans_handler.yml` — copied from oddb.org; its shortcuts (`/medikamente`, `/interaktionen`, …) have nothing to do with YDIM.
- `Manifest.txt`, `pkg/*.gem`, `.travis.yml` — from the era when this shipped as a gem on Travis.
- `bin/ydimd` — the **server** daemon, vendored here in `4ad52d3`; it belongs to the ydim service, not to this front-end.
- `example_site/install_needed_sw.sh` still pins Ruby 2.4.0 and PostgreSQL 10.1, while `example_site/service/*/run` invoke `bundle-320` / `ruby-320` (Ruby 3.2). The run scripts reflect the current deployment.

## Code style

Existing files mix tabs and spaces, often within one file, and leave `module YDIM / module Html / module State` unindented with the class body starting at column 0. Match the file you are editing rather than reformatting — whitespace-only churn buries real changes in the diff. Source files carry a `#!/usr/bin/env ruby` + `# encoding: utf-8` header and an authorship comment line.
