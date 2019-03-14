# *loco*lamp: An example loco project

This is small demonstration of the [loco process manager](https://github.com/totten/loco). It defines a "LAMP" stack (e.g. Apache + MySQL + PHP + Redis + Mailcatcher) for *local development*. It uses software from the [nix package manager](https://nixos.org/nix/).

## Quick Start

Install the [nix package manager](https://nixos.org/nix/):

```
curl https://nixos.org/nix/install | sh
```

And then run:

```
$ nix-env -iA cachix -f https://cachix.org/api/v1/install && cachix use locolamp
$ git clone https://github.com/totten/locolamp
$ cd locolamp
$ nix-shell
[nix-shell]$ loco run
```

This will create a RAM-disk, initialize the data/configuration files in `.loco/var`, and launch the services in the foreground.  You can then open a web page, e.g.

* http://127.0.0.1:8000/

To stop the services, simply press `Ctrl-C`.

To start again, run `loco run` again. To destroy the ramdisk and any service data, run `loco clean`.

What if you want to change the configuration? Check the file-list and the cookbook/examples below.

## Files and Directories

* [default.nix](default.nix): List of software to download
* [.loco/loco.yml](.loco/loco.yml): List of services to execute
* [.loco/config](.loco/config): Configuration templates
* [web](web): Web root (containing any HTML/PHP/JS/CSS)

## Cookbook

* [Config files: Using alternate HTTP web-root](doc/cookbook/web-root.md)
* [Quick start: Using alternate HTTP web-root](doc/cookbook/quick-web-root.md)
* [Adding a new service (Mailcatcher)](doc/cookbook/mailcatcher.md)
* [Using PhpStorm with nix PHP](doc/cookbook/phpstorm.md)
* [Using locolamp in the default shel](doc/cookbook/default-shell.md)
