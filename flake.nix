{
  description = "Wasm4 fantasy console";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wasm4-bin = {
      url = "https://github.com/aduros/wasm4/releases/download/v2.6.0/w4-linux.zip";
      type = "file";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, wasm4-bin, ... }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        version = "2.6.0";
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = self.packages.${system}.wasm4-bin;

        packages.wasm4-bin = pkgs.stdenv.mkDerivation {
          pname = "w4";
          version = "2.6.0";

          src = wasm4-bin;

          nativeBuildInputs = with pkgs; [ unzip ];
          buildInputs = with pkgs; [ nodejs ];

          phases = [ "installPhase" ];

          installPhase = ''
            mv $src w4.zip
            mkdir -p $out/bin
            unzip w4.zip -d $out/bin
          '';
        };
      });
}
