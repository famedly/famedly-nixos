    { config, pkgs, lib, ... }:
    {
      imports = [
        ./clamav.nix
        ./osquery.nix
        ./git.nix
      ];
      systemd.packages = [ pkgs.drivestrike ];
      systemd.services.drivestrike.enable = true;
      environment.systemPackages = [ pkgs.drivestrike ];

      nixpkgs.overlays = [ (import ../packages/overlay.nix) ];
    }
