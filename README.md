# wasm4-nix: A nix-flake for wasm4 fantasy console

WIP.

I was able to package the web-devtool directory and the `w4` cli itself, but was unsuccessful in packaging the wasm4 runtime needed to run the carts.  The issue is that the web-devtools dependency is references with a relative link that looks up from runtimes/web directory like so:

```
wasm4/runtimes/web $ rg @wasm4 package.json
19:    "@wasm4/web-devtools": "file:../../devtools/web"
```

I'm unsure how to build this given this contraint.  `buildNpmPackage` from nixpkgs will download the npm dependencies for me but won't look outside the `runtimes/web` folder for additional files (understandably).  I'm not sure how to build this from the root directory itself either.

You should make a PR if you have any ideas.  I'll have to return to this when I become more familiar with derivations.
