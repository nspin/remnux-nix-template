let
  # HACK
  nixpkgs = builtins.getFlake "nixpkgs/${(builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked.rev}";
  pkgs = import nixpkgs {};
  this = pkgs.callPackage ./this.nix {};
in this // { inherit pkgs; }
