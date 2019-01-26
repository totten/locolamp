# *loco*lamp: An example loco project

This is small demonstration of the [loco process manager](https://github.com/totten/loco). It defines a "LAMP" stack (e.g. Apache + MySQL + PHP + Redis + Mailcatcher) for *local development*. It uses software from the [nix package manager](https://nixos.org/nix/).

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

## Example: Changing the HTTP web-root

By default, *loco*lamp configures Apache to use the `./web` (literally `$LOCO_PRJ/web`)) folder as the web-root. What if your web-root lives somewhere else, such as `$HOME/src/webapp`? Simply edit [.loco/loco.yml](.loco/loco.yml) and set the variable `HTTPD_ROOT=$HOME/src/webapp`.

(*Similarly, if you need to make a more nuanced changed to the configuration, edit the template [.loco/config/apache/conf/httpd.conf.loco.tpl](.loco/config/apache/conf/httpd.conf.loco.tpl).*)

These changes will not necessarily take effect on their own. You may need to reinitialize the Apache service before starting. This will overwrite/destroy any auto-generated state/configuration:

```
[nix-shell]$ loco init apache -f -v
[nix-shell]$ loco run
```

Since the services are only used by the local development project, I find it easier to destroy+reinitialize *all* services at the same time, which can be boiled down to one command -- the "force-run":

```
[nix-shell]$ loco run -f -v
```

## Example: Changing the HTTP web root - in one command

Suppose you've got a PHP web app (`$HOME/src/webapp`) and you want to run it with the *loco*lamp configuration.  You can combine several of the above codes (`HTTPD_ROOT=$HOME/src/webapp`, `nix-shell`, `loco init -f`, `loco run`) into one command:

```
$ cd locolamp
$ env HTTPD_ROOT=$HOME/webapp nix-shell --command 'loco run -f -v'
```

## Example: Adding a new sevice (Mailcatcher)

Mailcatcher is an email simulator which provides an SMTP service (usually on port 1025) and a webmail service (usually
on port 1080).  At the start, the introduction claimed that Mailcatcher is included, but that was a little lie -- it's
not included now, but we can add it.

First, (if it's running) shutdown `loco`. Exit the `nix-shell`. We want to start from a clean place.

Next, edit `default.nix`. In the list of `buildInputs`, add `pkgs.mailcatcher`. Run `nix-shell` and it will automatically download `mailcatcher` (along with any other missing packages).

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
