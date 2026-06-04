{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    devshells.default = {
      motd = "Hello world!";
      packages = [pkgs.nix];
      devshell.startup.cargo-nix-plugin.text = let
        plugin = inputs'.cargo-nix-plugin.packages.default;
      in ''
        # Load builtins.resolveCargoWorkspace into every `nix` invocation
        # in this shell. plugin-files points at the *directory*; Nix picks
        # the right .so/.dylib automatically.
        export NIX_CONFIG="plugin-files = ${plugin}/lib/nix/plugins''${NIX_CONFIG:+$NIX_CONFIG}"
      '';
    };
  };
}
