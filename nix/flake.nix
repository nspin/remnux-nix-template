{
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        inherit pkgs;

        packages = pkgs.callPackage ./this.nix {};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # ...
          ];
        };
      }
    );
}
