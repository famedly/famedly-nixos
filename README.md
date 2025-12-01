# Famedly NixOS flake

This is a flake containing a collection of outputs required for
developing with nix.

Among these:
- A basic system configuration module to conform with our ISMS on NixOS
- A devshell for Rust development at Famedly

## Usage

### Devshells

Devshells are self-contained development environments containing all
the development tools required, with specific, shared, reproducible
versions.

Since nix isn't limited to use on NixOS, these can be used on any
distro. We could make our dev environment setup quite a bit easier if
we started using this more extensively.

For now, this repo contains some basic toolchain devshells that
generally work.

#### Direnv

Using [direnv](https://direnv.net/) is recommended to auto-enable nix
environments in editors, especially on NixOS. This flake can be used
with the following `.envrc`, for example for rust development:

```
# .envrc
use flake github:famedly/famedly-nixos#rust
```

#### Pure nix

Alternatively, entering the environment before starting your editor is
an option too. This can be done like so:

```console
$ nix develop github:famedly/famedly-nixos#rust
$ code/emacs/nvim/vi/ed
```

### NixOS module

#### Drivestrike registration

Before the systemd service will work, you will need to register
drivestrike:

```console
# drivestrike register <registration code> "" https://app.drivestrike.com/svc/
```

#### Flakes

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    famedly-nixos.url = "git+ssh://git@github.com/famedly/famedly-nixos";
  };

  outputs =
    { nixpkgs, famedly-nixos, ... }@inputs:
    {
      nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        modules = [ ./configuration.nix ];
        specialArgs.flake-inputs = inputs;
      };
    };
}
```

```nix
# configuration.nix
{ flake-inputs, ... }:
{
  imports = [ flake-inputs.famedly-nixos.nixosModules.default ];

  famedly-hwp.osquery_secret_path = "/etc/secret/osquery_secret.txt";

  # Any other configuration here
}
```

##### Required files
The enroll secret of osquery is expected to be found in `famedly-hwp.osquery_secret_path`, which you should set in your own config.

## Maintenance & contributing

Please use nixpkgs-fmt (RFC edition).

Updating drivestrike can be done with the usual NixOS-style update script:

```console
$ nix run .#drivestrike.updateScript
```
