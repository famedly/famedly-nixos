nixos.wait_for_unit("default.target")

# Fails because registration has to happen first, and we can't
# register in a VM.
with subtest("Ensure drivestrike is running"):
    nixos.succeed("systemctl is-active drivestrike")
