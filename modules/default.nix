flake-inputs: {
  default =
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
        ./osquery.nix
        ./git.nix
      ];
      systemd.packages = [ drivestrike' ];
      systemd.services.drivestrike.enable = true;
      environment.systemPackages = [ drivestrike' ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
}
