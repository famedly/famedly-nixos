{
  system,
  nixpkgs,
  fenix,
  ...
}:
let
  pkgs = nixpkgs.legacyPackages.${system};
  fenix' = fenix.packages.${system};
  rust-stable = fenix.packages.${system}.stable;
  rust-nightly = fenix.packages.${system}.latest;
in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      (
        # Our toolchain is mostly rust-stable, but we use rustfmt from
        # nightly to get import ordering.
        with rust-stable;
        fenix'.combine [
          cargo
          rust-docs
          rust-std
          rustc
          rust-analyzer
          clippy

          rust-nightly.rustfmt
        ]
      )

      # We have some projects that use cargo workspaces, this tool makes
      # matching up dependencies between subcrates easier.
      cargo-autoinherit

      # We use nextest for testing, this cargo extension needs to be
      # installed for testing most of our projects
      cargo-nextest

      # TODO: Add cargo-udeps. It only works with a nightly rustc,
      # though, so we need to find a way to make it use a different rust
      # channel than the one we install for actual dev purposes.

      # Used universally in the rust ecosystem to locate system deps
      pkg-config

      # Used by anything web-related in the rust ecosystem in practice,
      # universally required by most famedly projects
      openssl
    ]
    # Used for code coverage, but currently only supported on linux
    ++ lib.optional (nixpkgs.lib.hasSuffix "linux" system) cargo-llvm-cov;
}
