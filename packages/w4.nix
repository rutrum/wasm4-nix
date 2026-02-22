{ pkgs, inputs, perSystem, ... }:
let
  version = "2.7.1";

  devtools = pkgs.buildNpmPackage {
    pname = "wasm4-devtools";
    inherit version;
    src = "${inputs.wasm4-src}/devtools/web";
    npmDepsHash = "sha256-XPSnhQLdzIKY2qCiIfTIXQ8rOm7Tg5nPW7XEE1gmxRo=";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/
      cp -r types $out/ 2>/dev/null || true
      cp package.json $out/
      cp -r node_modules $out/
      runHook postInstall
    '';
  };

  web-runtime = pkgs.buildNpmPackage {
    pname = "wasm4-web-runtime";
    inherit version;
    src = inputs.wasm4-src;
    sourceRoot = "source/runtimes/web";
    npmDepsHash = "sha256-9QeN73OBYovXPJ6GKJ9jAvZ4eA/2estvq1M816YzLJk=";

    postPatch = ''
      ${pkgs.jq}/bin/jq 'del(.dependencies."@wasm4/web-devtools")' package.json > package.json.tmp
      mv package.json.tmp package.json
      ${pkgs.jq}/bin/jq 'del(.packages."node_modules/@wasm4/web-devtools") | del(.packages."../../devtools/web")' package-lock.json > package-lock.json.tmp
      mv package-lock.json.tmp package-lock.json
    '';

    preBuild = ''
      mkdir -p node_modules/@wasm4
      ln -s ${devtools} node_modules/@wasm4/web-devtools
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  };
in
pkgs.buildNpmPackage {
  pname = "w4";
  inherit version;
  src = "${inputs.wasm4-src}/cli";
  npmDepsHash = "sha256-p+sh1BHHmOY9mvUDOA/9KgoWTXwBfrlK2tqhXLQSeXk=";
  dontNpmBuild = true;

  postPatch = ''
    rm -rf assets/runtime || true
    mkdir -p assets/runtime
    cp -r ${web-runtime}/* assets/runtime/

    mkdir -p assets/natives
    cp ${perSystem.self.wasm4}/bin/wasm4 assets/natives/wasm4-linux
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
}
