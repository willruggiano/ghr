{inputs, ...}: {
  imports = [
    inputs.treefmt.flakeModule
  ];

  perSystem = {
    config,
    lib,
    ...
  }: {
    devshells.default.packages = [config.packages.treefmt];

    jail.additionalCombinators = cs:
      with cs; [
        (add-pkg-deps [config.packages.treefmt])
      ];

    packages.treefmt = config.treefmt.build.wrapper;

    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        # Nix
        alejandra.enable = true;
      };
    };
  };
}
