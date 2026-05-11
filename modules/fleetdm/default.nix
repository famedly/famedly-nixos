{ config, lib, ... }:
let
  cfg = config.famedly-hwp.fleet;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "famedly-hwp" "osquery_secret_path" ]
      [ "famedly-hwp" "fleet" "enroll-secret" "path" ]
    )
  ];

  options.famedly-hwp.fleet.enroll-secret = {
    path = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.path;
      example = "/etc/secrets/fleet-enroll.key";
      description = /* md */ ''
        Path to a file with the fleet enroll secret.

        The secret - as well as any further instructions and explanations -
        can be found [on
        notion](https://www.notion.so/famedly/Hardware-a5f914e033c241ea97fa2e5855d464d8?source=copy_link#ff572210323342739a2c0fad07c82339).
      '';
    };

    systemd-cred-id = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "fleet-enroll-key";
      description = /* md */ ''
        ID of the systemd credential containing the fleet enroll key.

        To create the systemd credential, use the following command:

            echo '<enroll-key>' | systemd-creds encrypt - /etc/credstore.encrypted/fleet-enroll-key
      '';
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion =
            let
              inherit (cfg.enroll-secret) path systemd-cred-id;
            in
            path == null || systemd-cred-id == null;

          message = /* md */ ''
            The two famedly-hwp.fleet.enroll-secret variants are mutually
            exclusive; either use the path *or* the systemd-cred.

            If you prefer to use the path, explicitly set the systemd-cred to
            `null`:

                famedly-hwp.fleet.enroll-secret = {
                  path = "/etc/secret/osquery_secret.txt";
                  systemd-cred = null;
                }
          '';
        }
      ];

      services.orbit = {
        enable = true;
        debug = true;

        fleetUrl = "https://fleet.famedly.com";
        fleetCertificate = ./fleet.pem;
        hostIdentifier = "uuid";

        # This enrolls using a TPM 2.0 key. For now we disable this,
        # because we don't know if all hosts support TPM 2.0 yet.
        #
        # TODO(andre): Review once we can write queries to figure out
        # if all laptops do support TPM 2.0.
        fleetManagedHostIdentityCertificate = false;

        # For now we don't enable scripts; we still need to do some
        # testing to figure out how to do this correctly, and we don't
        # want to accidentally scupper people's computers.
        enableScripts = false;
      };
    }

    (lib.mkIf (cfg.enroll-secret.systemd-cred-id != null) {
      systemd.services.orbit.serviceConfig.LoadCredentialEncrypted = [
        cfg.enroll-secret.systemd-cred-id
      ];

      services.orbit.enrollSecretPath = "/run/credentials/orbit.service/${cfg.enroll-secret.systemd-cred-id}";
    })

    (lib.mkIf (cfg.enroll-secret.path != null) {
      services.orbit.enrollSecretPath = cfg.enroll-secret.path;
    })
  ];
}
