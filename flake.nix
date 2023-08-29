{
  description = "Wasm4 fantasy console";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wasm4 = {
      url = "github:aduros/wasm4/v2.5.4";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, wasm4, ... }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        name = "wasm4";
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = self.packages.${system}.${name};
        packages.${name} = pkgs.buildNpmPackage {
          pname = "w4";
          version = "2.5.4";
          src = "${wasm4}/cli";
          npmDepsHash = "sha256-40UZgS26MRIU62tl+BcRrLMQ7JewQ2OZ5YhrWetheCI=";

          nativeBuildInputs = with pkgs; [
            nodejs
          ];

          buildPhase = ''
            npm install;
          '';
        };

        devShells.default = pkgs.mkShell {
          inherit name;
          buildInputs = with pkgs; [
            nodejs
          ];
        };
      });
}
