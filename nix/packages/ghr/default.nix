{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.rust-overlay.overlays.default
      ];
    };

    devshells.default.packages = [config.packages.toolchain];

    packages = {
      toolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain:
        toolchain.default.override {
          extensions = ["rust-src"];
        });

      ghr = let
        cargoNix = inputs.cargo-nix-plugin.lib {
          inherit pkgs;
          src = ../../..;
        };
      in
        cargoNix.rootCrate.build;
    };
  };
}
