flake-inputs: {
  default =
    { pkgs, ... }:
    {
      imports = [
        ./clamav.nix
        ./fleetdm
        ./git.nix
        ./cachix.nix

        flake-inputs.fleet-nixos.nixosModules.fleet-nixos
      ];

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
    };
}
