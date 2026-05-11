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

#### Flakes

> [!WARNING]
>
> The NixOS modules aren't *entirely* declarative, because we can't
> deploy secrets using a git repository; secrets must be supplied
> manually at the moment.
>
> Don't skip the [enrolling credentials](#enrolling-credentials)
> heading.

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
}
```

#### Enrolling credentials

Our modules support [systemd
credentials](https://systemd.io/CREDENTIALS/) natively. To supply the
credentials, they must be placed in appropriately-named files using
the `systemd-creds` command.

This looks something like:

```console
echo '<credential>' | systemd-creds encrypt - /etc/credstore.encrypted/<credential-id>
```

Currently, we use these credential IDs:

| ID               | Purpose                                 | Source |
| ---------------- | --------------------------------------- | ------ |
| fleet-enroll-key | Enrolls the device into a fleetdm group | https://www.notion.so/famedly/Hardware-a5f914e033c241ea97fa2e5855d464d8?source=copy_link#ff572210323342739a2c0fad07c82339 |

### Cachix

A pre-configured module is provided to use the Famedly Cachix instance.
To use it, your system configuration should contain:

```nix
# configuration.nix
{ flake-inputs, ... }:
{
  imports = [ flake-inputs.famedly-nixos.nixosModules.default ];

  famedly-cachix.enable = true;
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
  '';
}
```

The `netrc-file`, here in `/etc/nix/netrc`, should have at least the following contents:

```
machine famedly.cachix.org password <AUTH_TOKEN>
```

where an `<AUTH_TOKEN>` can be generated on the Cachix website. If you actually work
here, you should be able to go to https://app.cachix.org/personal-auth-tokens
and login with GitHub to generate an auth token.

## Maintenance & contributing

Please use nixpkgs-fmt (RFC edition).
