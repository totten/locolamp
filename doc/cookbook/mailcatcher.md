## Cookbook: Adding a new sevice (Mailcatcher)

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
