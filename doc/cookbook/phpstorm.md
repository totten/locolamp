## Cookbook: Using PhpStorm with nix PHP

In the "Quick Start", we used `nix-shell` to open a subshell with a suitable
environment.  For example, it sets a `PATH` which includes the PHP folder
(`/nix/store/03z7c0xrd530lpcc7f57s5mfaqg0fdvj-php-7.2.13/bin`).

In PhpStorm, the IDE needs a reference to the PHP interpreter.  Pointing it
to `/nix/store/03z7...` is a bit ugly (and hard to maintain during
upgrades).  Instead, you can create a "profile" -- a folder which links to
all the packages from `locolamp`.  In this example, we put all the packages
under `/nix/var/nix/profiles/per-user/$USER/locolamp`:

```
$ cd locolamp
$ nix-env -p /nix/var/nix/profiles/per-user/$USER/locolamp -i -f .
```

Now, to register this copy of PHP in PhpStorm (or any other IDE), 
use `/nix/var/nix/profiles/per-user/$USER/locolamp/bin/php`.

Note: Upgrades won't be automatic; so you may want to periodically
reinstall the profile.
