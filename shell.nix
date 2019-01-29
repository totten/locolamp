{
  pkgs ? import <nixpkgs> {
    inherit system;
  },
  system ? builtins.currentSystem,
}:

pkgs.stdenv.mkDerivation rec {

  name = "locolamp";

  buildInputs = import ./default.nix { inherit system; };

  ## When starting `nix-shell`, load all the project-wide config variables from `loco.yml`.
  ## This ensures that, e.g., the `mysql` and `mysqldump` commands have the right `MYSQL_HOME`.
  shellHook = ''
    eval $(loco env --export)
  '';

}
