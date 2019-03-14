## Cookbook: Quick start with alternate HTTP web-root

You can combine several of the codes from [Config files with alternate the HTTP web-root](doc/cookbook/web-root.md)
(e.g. `HTTPD_ROOT=$HOME/src/webapp`, `nix-shell`, `loco init -f`, `loco run`) and make one pithy variant:

```
$ git clone https://github.com/totten/locolamp
$ cd locolamp
$ env HTTPD_ROOT=$HOME/src/webapp nix-shell --command 'loco run -f -v'
```
