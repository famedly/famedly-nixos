{
  flake-inputs,
  lib,
  nodes,
  pkgs,
  ...
}:
{
  imports = [ flake-inputs.self.nixosModules.default ];

  users.users.famedly = {
    isNormalUser = true;
    password = "insecure";
  };

  systemd.services = {
    # Disable for now, since this fails if the clamav DB cannot be
    # reached, causing the whole `default.target` to fail.
    clamav-freshclam.enable = false;

    setup-credentials = {
      after = [ "systemd-random-seed.service" ];
      wantedBy = [ "systemd-random-seed.service" ];
      script = ''
        echo 'example@famedly.com' | ${lib.getExe' pkgs.systemd "systemd-creds"} encrypt - /etc/credstore.encrypted/drivestrike-registration-code
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };

  networking.hosts = {
    ${nodes.fake-drivestrike.networking.primaryIPAddress} = [ "app.drivestrike.com" ];
  };

  security.pki.certificateFiles = [
    nodes.fake-drivestrike.services.nginx.virtualHosts."app.drivestrike.com".sslCertificate
  ];
}
