{
  description = "YuE Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-python, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

        python38 = nixpkgs-python.packages.${system}."3.8";
        micromamba = pkgs.micromamba;
        cudatoolkit = pkgs.cudaPackages_11.cudatoolkit;

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            python38
            micromamba
            cudatoolkit
            pkgs.git
            pkgs.git-lfs
          ];

          shellHook = ''
            export PATH="$PWD/.venv/bin:$PATH"
            export CUDA_HOME=${cudatoolkit}
            git lfs install

            # Initialize micromamba shell
            eval "$(micromamba shell hook --shell bash)"

            if [ ! -d ".venv" ]; then
              echo "Creating Conda environment..."
              # Use ./ to specify relative path
              micromamba create -y -p ./.venv \
                -c pytorch -c nvidia -c conda-forge \
                python=3.8 \
                pytorch \
                torchvision \
                torchaudio \
                pytorch-cuda=11.8
              echo "Activating Conda environment..."
            fi

            micromamba activate ./.venv
            
            # Install Flash Attention for GPU memory optimization
            if ! python -c "import flash_attn" 2>/dev/null; then
              echo "Installing Flash Attention..."
              pip install flash-attn --no-build-isolation
            fi
            
            echo "Environment ready."
          '';
        };
      }
    );
}
