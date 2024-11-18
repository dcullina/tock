{
  description = "flake for tock";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix/1a92c6d75963fd594116913c23041da48ed9e020"; # this is the commit hash specified in shell.nix
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tockloader = {
      # url = "github:tock/tockloader/v1.12.0";
      url = "git+file:///Users/dylan/Documents/Projects/tockloader";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, fenix, tockloader, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config = {
            allowUnfree = true;
          };
        };

        rustBuild = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-WXllA4dqR/yihB3daUxS89PEF6UNwXH1xd3hETeioZ0=";
        };
        # tockloaderZZ = pkgs.callPackage "${tockloader}/default.nix" {};
        # tockloaderZZ = import "${tockloader}/default.nix" { inherit pkgs; };
        tockloaderZZ = import (pkgs.fetchFromGitHub {
          owner = "tock";
          repo = "tockloader";
          rev = "v1.12.0";
          sha256 = "sha256-VgbAKDY/7ZVINDkqSHF7C0zRzVgtk8YG6O/ZmUpsh/g=";
        }) { inherit pkgs; };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            name = "tock-dev2";
            buildInputs = with pkgs; [
              openocd

              python3Full
              rustBuild
              # tockloaderZZ

              python3Packages.cxxfilt

              qemu
            ];
          
            LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";

            NO_RUSTUP = "1";

            shellHook = ''
              unset OBJCOPY
              unset OBJDUMP
            '';
          };
        };
      }
    );
}
