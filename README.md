# Famedly NixOS module

This is a module for setting up basic system configuration to conform
with our ISMS on NixOS!

## Usage

### Drivestrike registration

Before the systemd service will work, you will need to register
drivestrike:

```console
# drivestrike register <registration code> "" https://app.drivestrike.com/svc/
```

### Include

```nix
# configuration.nix
{
  imports = [ ./famedly-nixos ];

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
$ nix run .#drivestrike.updateScript
```
