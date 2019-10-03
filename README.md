# *loco*lamp: An example loco project

This is small demonstration of the  [nix package manager](https://nixos.org/nix/) and [loco process manager](https://github.com/totten/loco). It defines a "LAMP" stack (e.g. Apache + MySQL + PHP + NodeJS + Redis + Mailcatcher) for *local development*.

## Quick Start

Install the [nix package manager](https://nixos.org/nix/):

```
$ curl https://nixos.org/nix/install | sh
```

And then run:

```
$ nix-env -iA cachix -f https://cachix.org/api/v1/install && cachix use locolamp
$ git clone https://github.com/totten/locolamp
$ cd locolamp
$ nix-shell
[nix-shell]$ loco run
```

The last command (`loco run`) starts the services (e.g. Apache + MySQL etal). It creates a RAM-disk for storing service data (`.loco/var`); initializes the data/configuration files; and launch the services in the foreground.  You can then open a web page, e.g.

* http://127.0.0.1:8000/

To run CLI commands (such as `php` or `mysql`), open a new console tab and start `nix-shell` again:

```
$ cd locolamp
$ nix-shell

[nix-shell:~/src/locolamp]$ mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 10.2.17-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE exampledb;
Query OK, 1 row affected (0.00 sec)
```

To stop the services, return to the original console (`loco run`) and press `Ctrl-C`.

To start again, run `loco run` again.

To destroy the ramdisk and any service data, run `loco clean`.

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
* [Using locolamp in the default shell](doc/cookbook/default-shell.md)
