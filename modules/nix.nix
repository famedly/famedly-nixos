{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.famedly-cachix = {
    enable = lib.mkEnableOption "Famedly Cachix Module";
  };

  config = lib.mkMerge [
    # We use Lix for its slightly better feature set and active
    # development; cppnix is woefully undermaintained due to community
    # issues.
    {
      nixpkgs.overlays = [
        (final: prev: {
          inherit (prev.lixPackageSets.stable)
            nixpkgs-review
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        })
      ];

      nix.package = pkgs.lixPackageSets.stable.lix;
    }

    (lib.mkIf config.famedly-cachix.enable {
      nix.settings = {
        substituters = [
          "https://cache.nixos.org"
          "https://famedly-oss.cachix.org"
          "https://famedly.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "famedly-oss.cachix.org-1:WdEnFSvKeI7CRgbEDkgzd8LgtkzfxOT8t274YIGvTE4="
          "famedly.cachix.org-1:eJntK6EfNdeiHeOY9QwR4gzUkNCp/l1F8N052vplx/I="
        ];
      };
    })
  ];
}
