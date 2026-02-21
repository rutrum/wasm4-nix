# wasm4-nix

Nix flake for [wasm4](https://wasm4.org), a WebAssembly fantasy console.

## Running

Play a cart:

```sh
nix run github:rutrum/wasm4-nix -- game.wasm
```

Or add to your environment:

```nix
environment.systemPackages = [
  wasm4-nix.packages.${system}.wasm4
];
```

## Development

Add to your `flake.nix`:

```nix
{
  inputs.wasm4-nix.url = "github:rutrum/wasm4-nix";
}
```

Add `w4` to a dev shell:

```nix
devShells.default = pkgs.mkShell {
  buildInputs = [
    wasm4-nix.packages.${system}.w4
  ];
};
```

## Packages

| Package | Description |
|---------|-------------|
| `wasm4` (default) | Native runtime for playing carts |
| `w4` | CLI for development: watch, bundle, png2src |
| `web-runtime` | Web runtime assets (used internally for w4) |
| `devtools` | Browser developer tools (used internally for w4) |
