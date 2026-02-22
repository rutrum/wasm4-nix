{
  description = "WASM-4 fantasy console";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    wasm4-src = {
      url = "github:aduros/wasm4/v2.7.1";
      flake = false;
    };

    wasm4-src-full = {
      url = "git+https://github.com/aduros/wasm4?ref=refs/tags/v2.7.1&submodules=1";
      flake = false;
    };
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
