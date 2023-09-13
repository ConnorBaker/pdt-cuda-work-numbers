{
  inputs = {
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixGL = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:guibou/nixGL";
    };
    nixos-generators = {
      inputs.nixlib.follows = "nixpkgs-lib";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nixos-generators";
    };
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-ta1-pre.url = "github:NixOS/nixpkgs/ad1abff502281b7fea02f62276c7af2cb760c23d";
    nixpkgs-ta1-post.url = "github:NixOS/nixpkgs/pull/240498/head";
    nixpkgs-ta2-pre.url = "github:NixOS/nixpkgs/fb11cd49294c4cbb3bd6a56f50f9b8cba2cac949";
    nixpkgs-ta2-post.url = "github:NixOS/nixpkgs/pull/238465/head";
    nixpkgs-ta3-pre.url = "github:NixOS/nixpkgs/9a12fb6936d9d21f6bb602c68d1b41ec16bfc7d4";
    nixpkgs-ta3-post.url = "github:NixOS/nixpkgs/pull/249259/head";
    pre-commit-hooks-nix = {
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:cachix/pre-commit-hooks.nix";
    };
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        ./nix
      ];
      perSystem = {config, ...}: {
        nix-cuda-test = {
          cuda = {
            capabilities = ["8.9"];
            version = "11.8";
            forwardCompat = false;
          };
          nvidia.driver = {
            hash = "sha256-L51gnR2ncL7udXY2Y1xG5+2CU63oh7h8elSC4z/L7ck=";
            version = "535.104.05";
          };
          python = {
            optimize = false;
            version = "3.10";
          };
        };
        pre-commit.settings = {
          hooks = {
            # Formatter checks
            treefmt.enable = true;

            # Nix checks
            deadnix.enable = true;
            nil.enable = true;
            statix.enable = true;

            # Shell checks
            shellcheck.enable = true;
          };
          # Formatter
          settings.treefmt.package = config.treefmt.build.wrapper;
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            # Nix
            alejandra.enable = true;

            # Shell
            shfmt.enable = true;
          };
        };
      };
    };
}
