{
  description = "WASM-4 fantasy console";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = "2.7.1";

        src = pkgs.fetchFromGitHub {
          owner = "aduros";
          repo = "wasm4";
          rev = "v${version}";
          hash = "sha256-QZtPqq92SXmH5DbyTgyHK+GG2TZglRpTKyX2tCd2xd8=";
        };

        # Stage 1: Build devtools (no local dependencies)
        wasm4-devtools = pkgs.buildNpmPackage {
          pname = "wasm4-devtools";
          inherit version;
          src = "${src}/devtools/web";

          npmDepsHash = "sha256-XPSnhQLdzIKY2qCiIfTIXQ8rOm7Tg5nPW7XEE1gmxRo=";

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            # Keep dist/ structure - package.json references dist/web-devtools.js
            cp -r dist $out/
            cp -r types $out/ 2>/dev/null || true
            cp package.json $out/
            # Include node_modules so dependencies like 'lit' are resolvable
            cp -r node_modules $out/
            runHook postInstall
          '';
        };

        # Stage 2: Build runtime - use full source for path resolution
        wasm4-runtime = pkgs.buildNpmPackage {
          pname = "wasm4-runtime";
          inherit version src;

          # Build from runtimes/web subdir but keep full source for relative imports
          sourceRoot = "source/runtimes/web";

          npmDepsHash = "sha256-9QeN73OBYovXPJ6GKJ9jAvZ4eA/2estvq1M816YzLJk=";

          # Remove the file: dependency - we'll provide devtools manually
          postPatch = ''
            ${pkgs.jq}/bin/jq 'del(.dependencies."@wasm4/web-devtools")' package.json > package.json.tmp
            mv package.json.tmp package.json

            # Remove devtools entries from package-lock.json
            ${pkgs.jq}/bin/jq 'del(.packages."node_modules/@wasm4/web-devtools") | del(.packages."../../devtools/web")' package-lock.json > package-lock.json.tmp
            mv package-lock.json.tmp package-lock.json
          '';

          preBuild = ''
            # Link the pre-built devtools into node_modules
            mkdir -p node_modules/@wasm4
            ln -s ${wasm4-devtools} node_modules/@wasm4/web-devtools
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r dist/* $out/
            runHook postInstall
          '';
        };

        # Stage 3: Build CLI (needs runtime assets)
        wasm4 = pkgs.buildNpmPackage {
          pname = "wasm4";
          inherit version;
          src = "${src}/cli";

          npmDepsHash = "sha256-p+sh1BHHmOY9mvUDOA/9KgoWTXwBfrlK2tqhXLQSeXk=";

          # Don't build - CLI is just JavaScript
          dontNpmBuild = true;

          postPatch = ''
            # Remove the runtime symlink and copy built runtime
            rm -rf assets/runtime || true
            mkdir -p assets/runtime
            cp -r ${wasm4-runtime}/* assets/runtime/
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/wasm4 $out/bin
            cp -r . $out/lib/wasm4/

            makeWrapper ${pkgs.nodejs}/bin/node $out/bin/w4 \
              --add-flags "$out/lib/wasm4/cli.js"

            runHook postInstall
          '';

          nativeBuildInputs = [ pkgs.makeWrapper ];

          meta.mainProgram = "w4";
        };

      in {
        packages = {
          default = wasm4;
          inherit wasm4 wasm4-runtime wasm4-devtools;

          # Convenience aliases
          devtools = wasm4-devtools;
          runtime = wasm4-runtime;
        };
      }
    );
}
