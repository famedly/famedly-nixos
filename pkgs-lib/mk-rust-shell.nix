{
  self,
  nixpkgs,
  fenix,
  system,
  ...
}:
let
  inherit (nixpkgs) lib;
  pkgs = nixpkgs.legacyPackages.${system};
  fenix' = fenix.packages.${system};
in
/**
  Custom rust shell builder.

  Example
  =======

  ```nix
  famedly-nixos.pkgsLib.x86_64-linux.mkRustShell {
    clippyConfigOverrides = {
      allow-dbg-in-tests = true;
    };

    clippyLintOverrides = {
      unsafe_code = "forbid";
      vec_resize_to_zero = "warn";
      wildcard_imports = "allow";
      while_float = "deny";
    };

    packages = [
      pkgs.protobuf
    ];
  }
  ```
*/
{
  /**
    Overrides to apply to the default clippy.toml configuration.

    Settings specified here will override the specific values
    set by the famedly-global configuration, but *not* settings
    that aren't specified in this attrset.

    See the [upstream list of configuration options][lint-config].

    [lint-config]: https://doc.rust-lang.org/clippy/lint_configuration.html
  */
  clippyConfigOverrides ? { },

  /**
    Overrides to apply to the default set of lints that clippy
    will check.

    Lint configurations defined here will override the default
    set of lints specified by the famedly-global configuration,
    but they will *not* affect lints not specified in this
    attrset.

    See the [upstream list of lints][lint-list].

    [lint-list]: https://rust-lang.github.io/rust-clippy/stable/index.html
  */
  clippyLintOverrides ? { },
  /**
    Additional packages to add to the shell package list.
  */
  packages ? [ ],
}@
/**
  Additional attributes to set on the `mkShell` invocation.

  The `clippy*Overrides` and `packages` args are not directly
  applied. For more complex overrides, use `.overrideAttrs`.
*/
attrs:
let
  rest = lib.removeAttrs attrs [
    "clippyConfigOverrides"
    "clippyLintOverrides"
    "packages"
  ];
in
pkgs.mkShell {
  packages =
    (lib.attrValues {
      # Our toolchain is mostly rust-stable, but we use rustfmt from
      # nightly to get import ordering.
      rustToolchain = fenix'.combine (
        lib.attrValues {
          inherit (fenix') stable;
          inherit (fenix'.latest) rustfmt;
        }
      );

      inherit (pkgs)
        # We have some projects that use cargo workspaces, this
        # tool makes matching up dependencies between subcrates
        # easier.
        cargo-autoinherit

        # We use nextest for testing, this cargo extension needs
        # to be installed for testing most of our projects
        cargo-nextest

        # Used universally in the rust ecosystem to locate system
        # dependencies
        pkg-config

        # Used by anything web-related in the rust ecosystem in
        # practice, universally required by most famedly projects
        openssl
        ;

      # Used to figure out if all crates in `Cargo.toml` are actually
      # used in a repository
      inherit (self.packages.${system}) cargo-udeps;
    })
    # Used for code coverage, but currently only supported on linux
    ++ lib.optional (lib.hasSuffix "linux" system) pkgs.cargo-llvm-cov
    ++ packages;
}
// rest
