# *loco*lamp: An example loco project

This is small demonstration of the [loco process manager](https://github.com/totten/loco). It defines a "LAMP" stack (e.g. Apache + MySQL + PHP + Redis + Mailcatcher) for local development. It uses software from the [nix package manager](https://nixos.org/nix/).

## Files and Directories

* [default.nix](default.nix): List of software to download
* [.loco/loco.yml](.loco/loco.yml): List of services to execute
* [.loco/config/apache](.loco/config/apache): Apache configuration templates
* [.loco/config/mysql](.loco/config/mysql): MySQL configuration templates
* [.loco/config/php-fpm](.loco/config/php-fpm): PHP-FPM configuration templates
* [.loco/config/redis](.loco/config/redis): Redis configuration templates
* [web](web): Web root (containing any PHP/JS/CSS)

## Usage

After installing the [nix package manager](https://nixos.org/nix/), run:

```
$ git clone https://github.com/totten/locolamp
$ cd locolamp
$ nix-shell
[nix-shell]$ loco run
```

This will initialize data/configuration files for each service and launch
them in the foreground.  You can then open a web page, e.g.

* http://127.0.0.1:8000/

To stop the services, simply press `Ctrl-C`.

What if you want to change the configuration?

Some really common options are exposed as environment variables:

```
[nix-shell]$ export HTTPD_PORT=8080
```

For other options, you may want to:

* Edit the file `.loco/loco.yml`
* Edit the file `.loco/config/apache/conf/httpd.conf.loco.tpl`

After making changes to the configuration, you probably need to
re-initialize the service and run it again, e.g

```
[nix-shell]$ loco init -f -v apache
[nix-shell]$ loco run
```

In practice, I don't like typing that much, and I often don't care about
keeping old data, so I just destroy everything and restart everything:

```
[nix-shell]$ loco run -f -v
```

Note: All generated data is stored in the folder `.loco/var`.

## Adding a new sevice (Mailcatcher)

Mailcatcher is an email simulator which provides an SMTP service (usually on
port 1025) and a webmail service (usually on port 1080).  The introduction
above claimed that Mailcatcher is included, but that was a little lie --
it's not included now, but we can add it.

First, download the binaries for `mailcatcher` by updating `default.nix`:

* If you have an open `[nix-shell]$` for `loco`, close that shell.
* Edit `default.nix`. In the list of `buildInputs`, add `pkgs.mailcatcher`.
* Open `nix-shell` anew. It will scan `default.nix` and auto-download `mailcatcher`.

Second, we need to add the `mailcatcher` service to loco:

* Edit `.loco/loco.yml`. Under `services`, add a section for `mailcatcher` and specify the `run` command:
  ```yaml
  services:
    mailcatcher:
      run: 'mailcatcher --smtp-port 1025 --http-port 1080 -f'
  ```
* Start the service with `loco run mailcatcher` or `loco run` (for all services).

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
