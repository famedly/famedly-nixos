# Famedly NixOS flake

This is a flake for setting up basic system configuration to conform
with our ISMS on NixOS!

## Usage

### Flakes

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
        # drivestrike currently doesn't appear to be built for other architectures, so sadly no other options
        system = "x86_64-linux";
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

#### Required files
The enroll secret of osquery is expected to be found in `famedly-hwp.osquery_secret_path`, which you should set in your own config.

## Maintenance & contributing

Please use nixpkgs-fmt (RFC edition).

Updating drivestrike can be done with the usual NixOS-style update script:

```console
nix run .#drivestrike.updateScript
```
