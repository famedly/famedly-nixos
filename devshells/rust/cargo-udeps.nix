# cargo-udeps requires nightly rustc to work, but our usual toolchain
# is stable.
#
# So we make a custom cargo-udeps binary wrapped with a rustc from the
# "default" (=nightly) fenix channel.
#
# TODO: This should be removed, and replaced with simply the unwrapped
# package whenever the required features land in rust stable.
{
  flake-inputs,

  stdenv,
  lib,

  runCommand,
  symlinkJoin,

  makeBinaryWrapper,
  cargo-udeps,
}:
let
  inherit (stdenv.hostPlatform) system;
  cargo-udeps-wrapped =
    runCommand "cargo-udeps-wrapped" { nativeBuildInputs = [ makeBinaryWrapper ]; }
      ''
        makeWrapper ${lib.getExe cargo-udeps} $out/bin/cargo-udeps \
          --prefix PATH : ${
            lib.makeBinPath [
              flake-inputs.fenix.packages.${system}.default.rustc
            ]
          }
      '';
in
symlinkJoin {
  name = "cargo-udeps";

  paths = [
    cargo-udeps-wrapped
    cargo-udeps
  ];
}
