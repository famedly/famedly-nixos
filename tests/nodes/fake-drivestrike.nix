{ lib, pkgs, ... }:
let
  certs =
    pkgs.runCommand "generate-fake-drivestrike-cert" { nativeBuildInputs = [ pkgs.openssl ]; }
      ''
        mkdir $out

        openssl ecparam -genkey -name prime256v1 | \
          openssl ec -outform PEM -out $out/key.pem

        openssl req -x509 \
          -batch \
          -new \
          -keyform PEM \
          -key $out/key.pem \
          -days 90 \
          -addext $'subjectAltName = ${
            lib.concatMapStringsSep "," (domain: "DNS:${domain}") [ "app.drivestrike.com" ]
          }' \
          -outform PEM \
          -out $out/cert.pem
      '';

in
{
  networking.firewall.allowedTCPPorts = [ 443 ];

  services.nginx = {
    enable = true;
    virtualHosts."app.drivestrike.com" = {
      onlySSL = true;
      locations."/drivestrike/svc".return = "200";

      sslCertificateKey = "${certs}/key.pem";
      sslCertificate = "${certs}/cert.pem";
    };
  };
}
