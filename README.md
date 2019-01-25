# locolamp: An example loco project

This is a small demonstration of using `nix-shell` and [loco](https://github.com/totten/loco).  It resembles a
traditional "LAMP" (Apache + MySQL + PHP) stack...  and throws in some extras (like Redis and mailcatcher).  All
services are running on `localhost`.

## Files and Directories

* [web](web): Web root
* [.loco/loco.yaml](.loco/loco.yaml): List of services
* [.loco/config/apache](.loco/config/apache): Apache configuration templates
* [.loco/config/mysql](.loco/config/mysql): MySQL configuration templates
* [.loco/config/php-fpm](.loco/config/php-fpm): PHP-FPM configuration templates
* [.loco/config/redis](.loco/config/redis): Redis configuration templates

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

* http://localhost:8000/

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
