## locolamp: Download a collection of binaries for use in "LAMP"-style development
## (Apache, MySQL, PHP, NodeJS, etc). Binaries are downloaded from nixpkgs.

## By default, we'll track nixpkgs v18.09. To upgrade, change the URL to a different branch/tag/commit.
{
  pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-18.09.tar.gz) {
    inherit system;
  },
  system ? builtins.currentSystem,
}:

let
  stdenv = pkgs.stdenv;
  allPkgs = pkgs;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  extraPkgs = {
    ## By default, we've pinned to a specific version of loco. We could grab a developmental version from Github or a local clone.
    loco = callPackage (fetchTarball https://github.com/totten/loco/archive/v0.1.0.tar.gz) {};
    # loco = callPackage (fetchTarball https://github.com/totten/loco/archive/master.tar.gz) {};
    # loco = callPackage /home/myuser/src/loco {};
  };

in stdenv.mkDerivation rec {
    name = "locolamp";

    ## This is the main list of packages that we want.
    buildInputs = [
      /* Major services */
      pkgs.php72
      pkgs.nodejs-8_x
      pkgs.apacheHttpd
      pkgs.mariadb
      pkgs.redis

      /* CLI utilities */
      extraPkgs.loco
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
    ];

  ## When starting `nix-shell`, load all the project-wide config variables from `loco.yml`.
  shellHook = ''
    eval $(loco env --export)
  '';
}
