flake-inputs: {
  default =
    { pkgs, ... }:
    {
      systemd.packages = [ flake-inputs.self.packages.${pkgs.system}.drivestrike ];
      systemd.services.drivestrike.enable = true;
      environment.systemPackages = [ flake-inputs.self.packages.${pkgs.system}.drivestrike ];
    };
}
