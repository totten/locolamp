## Cookbook: Changing the HTTP web-root

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

*See also: Quick start with alternate HTTP web-root](quick-web-root.md)*
