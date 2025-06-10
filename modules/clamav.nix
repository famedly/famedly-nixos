{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.clamav = {
    updater.enable = true;
    daemon.enable = true;
  };

  systemd = {
    services = {
      # Famedly's osquery checks for a process name of `clamd` and
      # `freshclam` - by default, however, systemd will use the filename,
      # which is an absolute path, and therefore this will look like clamd
      # is not running.
      #
      # TODO(tlater): Suggest an osquery that doesn't require this
      clamav-daemon.serviceConfig.ExecStart = lib.mkForce "@${pkgs.clamav}/bin/clamd clamd";

      clamav-freshclam = {
        serviceConfig = {
          Type = lib.mkForce "simple";
          ExecStart = lib.mkForce "@${pkgs.clamav}/bin/freshclam freshclam --daemon --foreground";
        };
        wantedBy = [ "clamav-daemon.service" ];
      };
    };

    # NixOS' freshclam (clamav updater) service is run as a timer by
    # default, but famedly expects it to run as a daemon.
    timers.clamav-freshclam.enable = false;
  };
}
