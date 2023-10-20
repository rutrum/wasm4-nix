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

          # dont remove dev dependencies
          dontNpmPrune = true;

          postInstall = ''
            # also make dev dependencies available
            mv node_modules/* $out/lib/node_modules
          '';
        };

        packages.runtime = let 
          web-devtool = self.packages.${system}.web-devtool;
        in pkgs.buildNpmPackage {
          pname = "wasm4-runtime";
          inherit version;

          src = "${wasm4}";
          sourceRoot = "source/runtimes/web";

          # with patch
          npmDepsHash = "sha256-Uswixjk5toTPCSaeKBZrND0Mqx35CBhMX5PHegeCJ9o=";

          nativeBuildInputs = with pkgs; [ 
            web-devtool
          ];

          patches = [ ./runtime.patch ]; # applied at sourceRoot
          postPatch = ''
            substituteInPlace package-lock.json package.json --subst-var-by web-devtool "${web-devtool}"
          '';
        };

        # packages.web-runtime3 = pkgs.buildNpmPackage {
        #   pname = "web-runtime3";
        #   inherit version;
        #   src = "${wasm4}";
        #   sourceRoot = "${wasm4}/runtimes/web";
        #   npmDepsHash = "sha256-NBxlHV0qPeCsQtAppk05g3b9SOHVEWS2JS7v1EEwQrY=";
        #   # makeCacheWritable = true;
   
        #   # nativeBuildInputs = [ self.packages.${system}.web-devtool ];

        #   # postUnpack = ''
        #   #   echo "POSTUNPACK PHASE"
        #   # '';

        #   # prePatch = ''
        #   #   echo "PREPATCH PHASE"
        #   # '';

        #   # preConfigure = ''
        #   #   echo "PRECONFIGURE PHASE"
        #   #   # rimraf not found
        #   #   # the ../../devtools/web folder is read only so dependencies cannot be installed
        #   #   # chmod u+x devtools/web
        #   # '';
        # };

        # packages.web-runtime = let 
        #   web-devtool = self.packages.${system}.web-devtool;
        # in pkgs.buildNpmPackage {
        #   pname = "wasm4-web-runtime";
        #   inherit version;
        #   #src = "${wasm4}/runtimes/web";
        #   src = "${wasm4}";
        #   sourceRoot = "source/runtimes/web";
        #   npmDepsHash = "sha256-PfVdHxhaz+tsrbfY0xtQqpE7NAyCf88bGVPqLBAOzik=";

        #   nativeBuildInputs = with pkgs; [ 
        #     jq
        #     fd
        #     web-devtool
        #   ];

        #   # dontPatch = true;
        #   
        #   prePatch = ''
        #     echo "PREPATCH"
        #     #sed -i '/prepare/d' package.json
        #     #sed -i 's/..\/..\/devtools\/web/@wasm4/g' package-lock.json
        #     #cat package-lock.json | jq '.dependencies."@wasm4/web-devtools" = "file:node_modules/@wasm4/web-devtools"' > temp.txt
        #     #mv temp.txt package.json
        #     #sed -i "s/import('@wasm4/import('\/node_modules\/@wasm4/" src/ui/app.ts
        #   '';

        #   # remove prepare command which installs web-devtool
        #   preConfigure = ''
        #     echo "PRECONFIGURE";
        #     # update dependencies to point to new directory

        #     # npm list


        #     # echo "PREPARE"
        #     # chmod 755 ../../devtools/web
        #     # ls -l ../../devtools
        #     # npm run prepare
        #     npm ci
        #   '';
        #   NODE_OPTIONS = "--openssl-legacy-provider";

        #   buildPhase = ''
        #     runHook preBuild
        #     echo "BUILD"
        #     npm run build
        #     runHook postBuild
        #   '';

        #   # dontNpmBuild = true;

        #   installPhase = ''
        #     ls
        #     npm install
        #     cp -r dist $out
        #   '';
        # };

        # devShells.default = pkgs.mkShell {
        #   name = "wasm4";
        #   buildInputs = with pkgs; [
        #     nodejs
        #   ];
        # };
      });
}
