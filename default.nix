## By defualt, pin to a revision nixpkgs 18.09
{pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/299814b385d2c1553f60ada8216d3b0af3d8d3c6.tar.gz) {
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
    #loco = callPackage (fetchTarball https://github.com/totten/loco/archive/master.tar.gz) {};
    loco = callPackage /Users/totten/src/loco {};
  };

in stdenv.mkDerivation rec {
    name = "locolamp";

    buildInputs = [
      /* Major services */
      pkgs.php72
      pkgs.nodejs-8_x
      pkgs.apacheHttpd
      pkgs.mariadb
      pkgs.redis
      pkgs.mailcatcher

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

  shellHook = ''
    eval $(loco env --export)
  '';
}
