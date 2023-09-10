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
        version = "2.5.4";
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = self.packages.${system}.cli;
        packages.cli = pkgs.buildNpmPackage {
          pname = "w4";
          inherit version;
          src = "${wasm4}/cli";
          npmDepsHash = "sha256-40UZgS26MRIU62tl+BcRrLMQ7JewQ2OZ5YhrWetheCI=";

          nativeBuildInputs = with pkgs; [
            nodejs
          ];

          buildPhase = ''
            npm install;
          '';

          # move runtime assets
          # prePatch = ''
          #   cp ${wasm4}/runtimes/web/dist $out/lib/node_modules/wasm4/assets/runtime
          # '';
        };

        packages.web-devtool = pkgs.buildNpmPackage {
          pname = "wasm4-web-devtool";
          inherit version;
          src = "${wasm4}/devtools/web";
          npmDepsHash = "sha256-GwYlRLXMqFMLWgbLHkWoOAxmspUf5/qbzgW9aTtCvtc=";

          buildPhase = ''
            npm install;
          '';
        };

        packages.web-runtime = pkgs.buildNpmPackage {
          pname = "wasm4-runtime";
          inherit version;
          src = "${wasm4}/runtimes/web";
          npmDepsHash = "sha256-PfVdHxhaz+tsrbfY0xtQqpE7NAyCf88bGVPqLBAOzik=";

          nativeBuildInputs = with pkgs; [ 
            jq
            self.packages.${system}.web-devtool 
          ];

          # remove prepare command which installs web-devtool
          preConfigure = ''
            # update dependencies to point to new directory
            cat package.json | jq '.dependencies."@wasm4/web-devtools" = "file:node_modules/@wasm4/web-devtools"' > temp.txt
            cat temp.txt
            mv temp.txt package.json

            sed -i '/prepare/d' package.json
            #sed -i 's/..\/..\/devtools\/web/@wasm4/g' package-lock.json
          '';

          buildPhase = ''
            #npm run prepare
            npm install
          '';

          installPhase = ''
            ls
            cp -r dist $out
          '';
        };

        devShells.default = pkgs.mkShell {
          name = "wasm4";
          buildInputs = with pkgs; [
            nodejs
          ];
        };
      });
}
