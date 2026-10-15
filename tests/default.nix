{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    checks.integration-tests =
      (pkgs.testers.runNixOSTest {
        name = "integration-tests";

        nodes = {
          fake-drivestrike = ./nodes/fake-drivestrike.nix;
          nixos = ./nodes/nixos.nix;
        };
        interactive.nodes.nixos = ./nodes/nixos-interactive.nix;

        testScript = builtins.readFile ./test-script.py;
      }).extendNixOS
        {
          module = { };
          specialArgs.flake-inputs = inputs;
        };
  };
}
