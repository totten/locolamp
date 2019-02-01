## locolamp: Download a collection of binaries for use in "LAMP"-style development
## (Apache, MySQL, PHP, NodeJS, etc). Binaries are downloaded from nixpkgs.
##
## This file is generally organized into sections:
## 1. Import a list of available software packages.
## 2. Pick a list of specific packages.
{
  system ? builtins.currentSystem,
}:

################################################################################
## Import a list of available software packages.
##
## Observe: The list of available software comes from Github (`https://github.com/OWNER/PROJECT/archive/REF.tar.gz`).
## The Github URLs can be changed to reference:
##
##  - Branches
##  - Tags or commits
##  - Unofficial forks (different owners/projects)
##
## Referencing a branch means that `nix-shell` will (from time to time) automatically get
## newer versions of the packages. Referencing a tag or commit means that
## the exact versions of the software will be locked.

let

  ####
  ## Import the standard package repository (nixpkgs v18.09). Assign it the name "pkgs".
  ##
  ## Observe: The name "pkgs" follows a coding-convention, but it's just a
  ## local variable.  We could call it anything (as long as we're consistent
  ## about it below).
  ##
  ## Observe: The notation `import (...url...) {...options...}` accepts a list of options.
  ## This can be useful if you need custom compilation options for some packages.

  pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.09.tar.gz) {
    inherit system;
  };

  ####
  ## Import an older version of the standard package repository (nixpkgs v18.03). Assign it the name "oldPkgs".
  ##
  ## Observe: PHP 5.6 and PHP 7.0 are no longer distributed in nixpkgs
  ## v18.09+.  But you can still get them from nixpkgs v18.03.
  ##
  ## Observe: This is not commonly done in the official "nixpkgs", but it's
  ## handy if you need to mix+match different versions.
  ##
  ## Observe: Older builds used libmysqlclient instead of mysqlnd.  That can
  ## be problematic with, e.g., Drush+Drupal 8.

  oldPkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) {
    inherit system;
    config = {
      php = {
        mysqlnd = true;
      };
    };
  };

  ####
  ## Import some specific packages that are not available in nixpkgs.

  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) pkgs) // overrides);

  ## By default, we download a specific version of loco.  But if you had a
  ## local codebase for development purposes, you could use that instead.

  loco = callPackage (fetchTarball https://github.com/totten/loco/archive/v0.2.1.tar.gz) {};
  # loco = callPackage /home/myuser/src/loco { inherit pkgs; };

  ramdisk = callPackage (fetchTarball https://github.com/totten/ramdisk/archive/5c699fbeb8ce3d8f3862a726e1e2684067b237dd.tar.gz) {};

  ## Generating php.ini requires some special work.
  phpExtLoader = extSpec: (callPackage ./.loco/pkgs/php-exts/default.nix ({ inherit pkgs; } // extSpec));

################################################################################
## Now, we have a list of available software packages.
## Let's define the "locolamp" project and include some specific dependencies.

in [
  ## Major services / runtimes
  ramdisk
  pkgs.apacheHttpd     /* ... or pkgs.nginx ... */
  pkgs.mariadb         /* ... or pkgs.mysql57, pkgs.mysql55 ... */
  pkgs.nodejs-10_x     /* ... or pkgs.nodejs-8_x, pkgs.nodes-6_x  ... */
  pkgs.redis           /* ... or pkgs.memcached ... */

  pkgs.php72           /* ... or pkgs.php71, oldPkgs.php70, oldPkgs.php56 ... */
  (phpExtLoader {
    zendExts = [
      pkgs.php72Packages.xdebug
    ];
    stdExts = [
      pkgs.php72Packages.redis
      pkgs.php72Packages.imagick
    ];
  })

  # pkgs.mailcatcher

  ## CLI utilities
  loco
  pkgs.bzip2
  pkgs.curl
  pkgs.git
  pkgs.gnutar
  pkgs.hostname
  pkgs.ncurses
  pkgs.patch
  pkgs.php72Packages.composer
  pkgs.rsync
  pkgs.unzip
  pkgs.which
  pkgs.zip

  ## Aside: Downloading a different version of PHP or MySQL or NodeJS is
  ## simple, but bear in mind: this is upgrading (or downgrading).  You
  ## may need to change configuration files to match.  Most services are
  ## pretty good about forward-compatibility, but some (*ahem* MySQL)
  ## may give errors and require edits to the configuration.
]
