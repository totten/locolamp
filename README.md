# *loco*lamp: An example loco project

This is small demonstration of the [loco process manager](https://github.com/totten/loco). It defines a "LAMP" stack (e.g. Apache + MySQL + PHP + Redis + Mailcatcher) for *local development*. It uses software from the [nix package manager](https://nixos.org/nix/).

## Quick Start

Install the [nix package manager](https://nixos.org/nix/) and then run:

```
$ git clone https://github.com/totten/locolamp
$ cd locolamp
$ nix-shell
[nix-shell]$ loco run
```

This will initialize the data/configuration files in `.loco/var` and launch the services in the foreground.  You can then open a web page, e.g.

* http://127.0.0.1:8000/

To stop the services, simply press `Ctrl-C`.

What if you want to change the configuration? Check the file-list and the examples below.

## Files and Directories

* [default.nix](default.nix): List of software to download
* [.loco/loco.yml](.loco/loco.yml): List of services to execute
* [.loco/config](.loco/config): Configuration templates
* [web](web): Web root (containing any HTML/PHP/JS/CSS)

## Example: Changing the HTTP web-root

By default, *loco*lamp configures Apache to use the `./web` folder (literally `$LOCO_PRJ/web`) as the web-root. What if your web-root lives somewhere else, such as `$HOME/src/webapp`? Simply edit [.loco/loco.yml](.loco/loco.yml) and set the variable `HTTPD_ROOT=$HOME/src/webapp`.

(*Similarly, if you need to make a more nuanced changes to the configuration, edit the template [.loco/config/apache/conf/httpd.conf.loco.tpl](.loco/config/apache/conf/httpd.conf.loco.tpl).*)

These changes will not necessarily take effect on their own. You may need to reinitialize the Apache service before starting. This will overwrite/destroy any auto-generated state/configuration:

```
[nix-shell]$ loco init apache -f -v
[nix-shell]$ loco run
```

Since the services are only used by the local development project, I often don't care about retaining the data. It's easier to destroy+reinitialize+run *all* services at the same time, which can be boiled down to one command:

```
[nix-shell]$ loco run -f -v
```

## Example: Quick start with alternate HTTP web-root

You can combine several of the above codes (`HTTPD_ROOT=$HOME/src/webapp`, `nix-shell`, `loco init -f`, `loco run`) yielding a pithy variant:

```
$ git clone https://github.com/totten/locolamp
$ cd locolamp
$ env HTTPD_ROOT=$HOME/src/webapp nix-shell --command 'loco run -f -v'
```

## Example: Adding a new sevice (Mailcatcher)

Mailcatcher is an email simulator which provides an SMTP service (usually on port 1025) and a webmail service (usually
on port 1080).  At the start, the introduction claimed that Mailcatcher was included.  That was a little lie -- it's
not included *now*, but we can add it!

First, (if it's running) shutdown `loco`. Exit the `nix-shell`. We want to start from a clean place.

Next, edit `default.nix`. In the list of dependencies, uncomment `pkgs.mailcatcher`. Run `nix-shell` and it will automatically download `mailcatcher` (along with any other missing packages).

Then, we need to add the `mailcatcher` service to `loco`. Edit `.loco/loco.yml` and add a section for `mailcatcher`:

  ```yaml
  services:
    mailcatcher:
      run: 'mailcatcher --smtp-port 1025 --http-port 1080 -f'
  ```

Start the service with `loco run mailcatcher` or `loco run` (for all services).

Of course, stylistically, this doesn't quite match the other services -- the
port numbers are hard-coded.  To be more conventional, you can read them
from the environment variables.  This requires editing `.loco/loco.yml`
again:

* Under `default_environment`, define the variables and their values:
  ```yaml
  default_environment:
  - MAIL_SMTP_PORT=1025
  - MAIL_HTTP_PORT=1080
  ```
* Under `services`, update the section for `mailcatcher` and specify the `run` command:
  ```yaml
  services:
    mailcatcher:
     run: 'mailcatcher --ip "$LOCALHOST" --smtp-port "$MAIL_SMTP_PORT" --http-port "$MAIL_HTTP_PORT" -f'
  ```

To see if the variables are being used, set a variable and (re)start the service, e.g.

```
[nix-shell]$ env MAIL_HTTP_PORT=1111 loco run -f -v mailcatcher
```

In a web browser, you should find the simulated webmail at http://127.0.0.1:1111 

## Example: PhpStorm with nix PHP

In the "Quick Start", we used `nix-shell` to open a subshell with a suitable
environment.  For example, it sets a `PATH` which includes the PHP folder
`/nix/store/03z7c0xrd530lpcc7f57s5mfaqg0fdvj-php-7.2.13/bin`.

In PhpStorm, the IDE needs a reference to the PHP interpreter.  Pointing it
to `/nix/store/03z7...` is a bit ugly (and hard to maintain during
upgrades).  Instead, you can create a "profile" -- a folder which links to
all the packages from `locolamp`.  In this example, we put all the packages
under `/nix/var/nix/profiles/per-user/$USER/locolamp`:

```
$ cd locolamp
$ nix-env -p /nix/var/nix/profiles/per-user/$USER/locolamp -i -f .
```

Note: Upgrades won't be automatic; so you may want to periodically
reinstall the profile.

## Example: Use locolamp in the default shell

In the "Quick Start", we used `nix-shell` to open a subshell with a suitable
environment.  We will always have to open a subshell before running commands
like `mysql` or `composer`.  I like this because it's easy to switch between
different configurations, however...  if you always use one configuration, then this
could feel inconvenient.

You can bring the full locolamp stack into your default shell (so that
`nix-shell` isn't needed on a day-to-day basis):

```
$ git clone https://github.com/totten/locolamp ~/src/locolamp
$ nix-env -i -f ~/src/locolamp/
```

And optionally load the environment variables from `loco.yml` at startup
by adding this to the shell initialization script (`~/.profile` or
`~/.bashrc`):

```bash
eval $( loco env --cwd ~/src/locolamp/ --export )
```

Note: Upgrades won't be automatic; so you may want to periodically
reinstall the profile.
