## locolamp: Download a collection of binaries for use in "LAMP"-style development
## (Apache, MySQL, PHP, NodeJS, etc). Binaries are downloaded from nixpkgs.
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

  pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.09.tar.gz) { inherit system; };

  ####
  ## Import an older version of the standard package repository (nixpkgs v18.03). Assign it the name "oldPkgs".
  ##
  ## Observe: PHP 5.6 and PHP 7.0 are no longer distributed in nixpkgs
  ## v18.09+.  But you can still get them from nixpkgs v18.03.
  ##
  ## Observe: This is not commonly done in the official "nixpkgs", but it's
  ## handy if you need to mix+match different versions.

  oldPkgs = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.03.tar.gz) { inherit system; };

  ####
  ## Import some specific packages that are not available in nixpkgs.

  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) pkgs) // overrides);

  ## By default, we download a specific version of loco.  But if you had a
  ## local codebase for development purposes, you could use that instead.

  loco = callPackage (fetchTarball https://github.com/totten/loco/archive/v0.1.1.tar.gz) {};
  # loco = callPackage /home/myuser/src/loco {};

################################################################################
## Now, we have a list of available software packages.
## Let's define the "locolamp" project and include some specific dependencies.

in pkgs.stdenv.mkDerivation rec {

    name = "locolamp";

    ## Define a list of packages required for "locolamp".
    buildInputs = [
      ## Major services
      pkgs.php72           /* ... or pkgs.php71, oldPkgs.php70, oldPkgs.php56 ... */
      pkgs.nodejs-6_x      /* ... or pkgs.nodejs-10_x, pkgs.nodes-6_x  ... */
      pkgs.apacheHttpd     /* ... or pkgs.nginx ... */
      pkgs.mariadb         /* ... or pkgs.mysql57, pkgs.mysql55 ... */
      pkgs.redis           /* ... or pkgs.memcached ... */
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
    ];

  ## When starting `nix-shell`, load all the project-wide config variables from `loco.yml`.
  ## This ensures that, e.g., the `mysql` and `mysqldump` commands have the right `MYSQL_HOME`.
  shellHook = ''
    eval $(loco env --export)
  '';

}
