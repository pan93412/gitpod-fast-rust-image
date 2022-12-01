# gitpod-fast-rust-image

The speed-optimized and feature-rich Rust Docker image for Gitpod.

## Features

- Use `mold` as the default linker and integrated `sccache` to speed up the compilation
- Pre-installed `cargo-workspace`, `cargo-udeps` and `neovim`.
- Bind `/bin/sh` to `/bin/bash` to make `NAPI-RS` and some scripts work correctly.
- With Rust nightly toolchain pre-installed.
- Dependencies are upgraded.

## Usage

Add the following line to your `.gitpod.yml`:

```yml
image: "pan93412/gitpod-fast-rust-image:main"
```

Done! 🎉 Besides, the following is my recommended VS Code extensions for Rust and Git:

```yml
vscode:
  extensions:
    # Rust
    - "rust-lang.rust-analyzer"
    - "Zerotaskx.rust-extension-pack"

    # Git
    - "cschleiden.vscode-github-actions"
    - "eamodio.gitlens"
    - "donjayamanne.githistory"
    - "mhutchie.git-graph"
```
