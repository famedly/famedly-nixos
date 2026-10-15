{ inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.famedly.drivestrike;
in
{
  options.famedly.drivestrike = {
    enable = lib.mkEnableOption "drivestrike disk wiping daemon - very insecure, don't use";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The drivestrike package to use";

      defaultText = lib.literalExpression "self'.drivestrike";
      default = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.drivestrike.overrideAttrs (drv: {
        meta = drv.meta // {
          # Yep, not much we can do, see the package definition for
          # details.
          #
          # This is necessary because unfortunately flakes integrate
          # poorly with NixOS - `nixpkgs.allowedInsecurePackages` &
          # co. don't work because that mutates `pkgs`, but this
          # package comes from `inputs.self`.
          #
          # We could alternatively mutate `inputs.nixpkgs`, but that
          # requires using `import nixpkgs { }`, which breaks' nix'
          # eval caching and therefore makes builds slower. This is
          # the lesser evil.
          knownVulnerabilities = [ ];
        };
      });
    };

    registration-code = {
      path = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        example = "/etc/secrets/drivestrike-registration-code";
        default = null;
        description = ''
          Path to a file with the drivestrike registration ID.

          The secret is your email address.
        '';
      };

      systemd-cred-id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "drivestrike-registration-code";
        description = ''
          ID of the systemd credential containing the drivestrike registration ID.

          The secret is your email address.

          To create the systemd credential, use the following command:

              echo '<registration-code>' | sudo systemd-creds encrypt - /etc/credstore.encrypted/drivestrike-registration-code
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.registration-code.systemd-cred-id != null || cfg.registration-code.path != null;
        message = "One of the famedly.drivestrike.registration-code sources must be set";
      }
    ];

    systemd = {
      packages = [ cfg.package ];

      services = {
        drivestrike-register = {
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          # Note: `cat`-ing a secret file is bad practice, since this
          # ends up in the process args, which are world-readable.
          #
          # Alas, we have no other options, since drivestrike demands
          # the secret is submitted that way. At least this service is
          # a oneshot that only runs once, ever, so the window of
          # exploitability is extremely short.
          #
          # But frankly, this is the least serious security issue with
          # using drivestrike.
          script = ''
            ${lib.getExe cfg.package} register $(cat ${
              if cfg.registration-code.systemd-cred-id != null then
                "$CREDENTIALS_DIRECTORY/${cfg.registration-code.systemd-cred-id}"
              else
                cfg.registration-code.path
            })
          '';

          serviceConfig = {
            Type = "oneshot";
            LoadCredentialEncrypted = lib.mkIf (cfg.registration-code.systemd-cred-id != null) [
              cfg.registration-code.systemd-cred-id
            ];
          };
          unitConfig.ConditionPathExists = "!/etc/drivestrike.conf";
        };

        drivestrike = {
          enable = true;
          wants = [ "drivestrike-register.service" ];
          after = [ "drivestrike-register.service" ];
          wantedBy = [ "multi-user.target" ];
        };
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
