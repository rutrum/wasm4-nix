# wasm4-nix

Nix flake for [WASM-4](https://wasm4.org), a WebAssembly fantasy console.

## Playing Games

Play a cart directly:

```sh
nix run github:rutrum/wasm4-nix -- game.wasm
```

Or, add to your `flake.nix`:

```nix
{
  inputs = {
    wasm4-nix.url = "github:rutrum/wasm4-nix";
  };
}
```

And add the WASM-4 runtime to your environment:

```nix
environment.systemPackages = [
  wasm4-nix.packages.${system}.wasm4
];
```

## Development

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
| `wasm4` (default) | Native runtime for playing `.wasm` files |
| `w4` | CLI for development |
