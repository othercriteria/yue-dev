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
            pkgs.gnumake
            pkgs.gcc11
          ];

          shellHook = ''    
            # Set micromamba to use project-local paths
            export MAMBA_ROOT_PREFIX="$PWD/.micromamba"
            export CONDA_PKGS_DIRS="$PWD/.micromamba/pkgs"
            export PATH="$PWD/.venv/bin:$PATH"
            export CUDA_HOME=${cudatoolkit}
            git lfs install

            # Initialize micromamba shell
            eval "$(micromamba shell hook --shell bash)"

            if [ ! -d ".venv" ]; then
              echo "Creating Conda environment..."
              micromamba create -y -p ./.venv \
                -c pytorch -c nvidia -c conda-forge \
                python=3.8 \
                pytorch==2.1.2 \
                torchvision==0.16.2 \
                torchaudio==2.1.2 \
                pytorch-cuda=11.8 \
                sentencepiece \
                tensorboard \
                omegaconf \
                einops \
                tqdm \
                transformers \
                pysoundfile \
                numpy \
                matplotlib \
                pip || exit 1

              micromamba activate ./.venv || exit 1
              
              # Install Flash Attention for GPU memory optimization
              if ! python -c "import flash_attn" 2>/dev/null; then
                echo "Installing Flash Attention..."
                pip install flash-attn==2.5.3 --no-build-isolation
              fi
              
              echo "Installing audiotools..."
              pip install git+https://github.com/descriptinc/audiotools || exit 1
            else
              micromamba activate ./.venv || exit 1
            fi
            
            echo "Environment ready."
          '';
        };
      }
    );
}
