{pkgs ? import <nixpkgs> {
    inherit system;
  },
  system ? builtins.currentSystem,
  noDev ? false,
  stdExts ? [],
  zendExts ? []
  }:

let

    stdenv = pkgs.stdenv;
#    stdExts = [phpPackages.redis phpPackages.memcached phpPackages.imagick];
#    zendExts = [phpPackages.xdebug];

    stdExtConcat = builtins.concatStringsSep " " stdExts;
    zendExtConcat = builtins.concatStringsSep " " zendExts;

in stdenv.mkDerivation rec {

    phpExtScript = ''
      #!/usr/bin/env bash
      for d in ${zendExtConcat} ; do
        for f in $d/lib/php/extensions/*.so ; do
          echo "zend_extension=$f"
        done
      done

      for d in ${stdExtConcat} ; do
        for f in $d/lib/php/extensions/*.so ; do
          echo "extension=$f"
        done
      done
    '';

    name = "php-exts";
    buildInputs = zendExts ++ stdExts;
    buildCommand = ''
      mkdir -p $out/bin
      echo "$phpExtScript" > $out/bin/php-exts
      chmod +x $out/bin/php-exts
    '';

}
