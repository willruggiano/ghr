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
        # evaluation warning: cargo-nix-plugin: API level mismatch.
        #                       nix builtin resolver = 0
        #                       lib/default.nix      = 2
        #                     Your nix was built against a different cargo-nix-plugin revision
        #                     than the lib/ you are evaluating. Rebuild/reload the plugin
        #                     against this checkout.
        # error:
        #        … while evaluating the attribute 'optionalValue.value'
        #          at «github:NixOS/nixpkgs/ffa10e26ae11d676b2db836259889f1f571cb14f?narHash=sha256-QfWfccTN%2B70ZQ4m2qlU9PiKfz2Yppq94058iJyARNwc%3D»/lib/modules.nix:1332:5:
        #          1331|
        #          1332|     optionalValue = if isDefined then { value = mergedValue; } else { };
        #              |     ^
        #          1333|   };
        #
        #        … while evaluating a branch condition
        #          at «github:NixOS/nixpkgs/ffa10e26ae11d676b2db836259889f1f571cb14f?narHash=sha256-QfWfccTN%2B70ZQ4m2qlU9PiKfz2Yppq94058iJyARNwc%3D»/lib/modules.nix:1332:21:
        #          1331|
        #          1332|     optionalValue = if isDefined then { value = mergedValue; } else { };
        #              |                     ^
        #          1333|   };
        #
        #        … while evaluating definitions from `/nix/store/ch5n4xdddid5859dy6c4i6lghqyx8016-source/modules/transposition.nix':
        #
        #        … while evaluating definitions from `/nix/store/6ayhas4aw5wm22ngy7r8p91a5q99smh6-source/nix/packages/ghr, via option perSystem':
        #
        #        (stack trace truncated; use '--show-trace' to show the full, detailed trace)
        #
        #        error: attribute 'resolveCargoWorkspace' missing
        #        at «github:anthropics/cargo-nix-plugin/063f2ddd83f700e6f7f49093f9dd8c8be076c8a4?narHash=sha256-qBTfTjf5zNsaYUbKrnb7P9%2BypoLEtDWN9C41NJ1Mb7I%3D»/lib/default.nix:290:28:
        #           289|   # Call the plugin builtin — auto-detect mode based on metadata presence
        #           290|   resolved = apiLevelGuard builtins.resolveCargoWorkspace (
        #              |                            ^
        #           291|     {
        cargoNix = inputs.cargo-nix-plugin.lib {
          inherit pkgs;
          src = ../../..;
        };
      in
        cargoNix.rootCrate.build;
    };
  };
}
