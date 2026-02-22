{ pkgs, inputs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "wasm4";
  version = "2.7.1";
  src = inputs.wasm4-src-full;
  sourceRoot = "source/runtimes/native";

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];

  buildInputs = [
    pkgs.xorg.libX11
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrandr
    pkgs.xorg.libXinerama
    pkgs.xorg.libXi
    pkgs.libxkbcommon
    pkgs.alsa-lib
    pkgs.libpulseaudio
  ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/libexec
    cp wasm4 $out/libexec/wasm4-unwrapped
    makeWrapper $out/libexec/wasm4-unwrapped $out/bin/wasm4 \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.alsa-lib pkgs.libpulseaudio ]}"
    runHook postInstall
  '';

  meta.mainProgram = "wasm4";
}
