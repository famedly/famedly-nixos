{ config, pkgs, ... }:
{
  programs.git.config = {
    init.defaultBranch = "main";
    pull.rebase = true;
    commit.gpgsign = true;
    log.showSignature = true;
  };
}
