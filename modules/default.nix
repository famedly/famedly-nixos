flake-inputs:
{ pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  drivestrike' = flake-inputs.self.packages.${system}.drivestrike.overrideAttrs (drv: {
    meta = drv.meta // {
      # Yep, not much we can do, see the package definition for
      # details.
      #
      # This is necessary because unfortunately flakes integrate
      # poorly with NixOS.
      knownVulnerabilities = [ ];
    };
  });
in
{
  imports = [
    ./clamav.nix
    ./fleetdm
    ./git.nix
    ./nix.nix

    flake-inputs.fleet-nixos.nixosModules.fleet-nixos
  ];

  systemd.packages = [ drivestrike' ];
  systemd.services.drivestrike.enable = true;
  environment.systemPackages = [ drivestrike' ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Ensure the systemd credstores exist so that we can use them to
  # provide secrets.
  systemd.tmpfiles.settings."10-credstore" = {
    "/etc/credstore".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };

    "/etc/credstore.encrypted".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
  };
}
