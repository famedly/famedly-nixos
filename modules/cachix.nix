{
  lib,
  config,
  ...
}:
{
  options.famedly-cachix = {
    enable = lib.mkEnableOption "Famedly Cachix Module";
  };
  config = lib.mkIf config.famedly-cachix.enable {
    nix.settings.substituters = [
      "https://cache.nixos.org"
      "https://famedly-oss.cachix.org"
      "https://famedly.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "famedly-oss.cachix.org-1:WdEnFSvKeI7CRgbEDkgzd8LgtkzfxOT8t274YIGvTE4="
      "famedly.cachix.org-1:eJntK6EfNdeiHeOY9QwR4gzUkNCp/l1F8N052vplx/I="
    ];
  };
}
