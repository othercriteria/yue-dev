{
  description = "YuE development environment";

  inputs = {
    nixpkgs.url = "github:NixPkgs/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };

        pythonEnv = pkgs.python38.withPackages (ps: with ps; [
          pytorch-bin
          torchvision-bin
          torchaudio-bin
          pip
          # Basic development tools
          ipython
          jupyter
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          name = "yue-dev";

          buildInputs = with pkgs; [
            pythonEnv
            git-lfs
            cudatoolkit_11_8
            # Basic development tools
            poetry
            black
          ];

          shellHook = ''
            export PYTHONPATH="$PWD:$PYTHONPATH"
            export LD_LIBRARY_PATH="${pkgs.cudatoolkit_11_8}/lib:$LD_LIBRARY_PATH"
          '';
        };
      });
} 