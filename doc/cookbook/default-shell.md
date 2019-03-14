## Cookbook: Use locolamp in the default shell

In the "Quick Start", we used `nix-shell` to open a subshell with a suitable
environment.  We will always have to open a subshell before running commands
like `mysql` or `composer`.  I like this because it's easy to switch between
different configurations, however...  if you always use one configuration, then this
could feel inconvenient.

You can bring the full locolamp stack into your default shell (so that
`nix` and `nix-shell` aren't needed on a day-to-day basis):

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
