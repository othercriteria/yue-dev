# YuE Reproducible Build

A reproducible development environment for [YuE](https://github.com/multimodal-art-projection/YuE),
using Nix flakes.

## GPU

This project requires a GPU with CUDA support. It should work out of the box with
a NVIDIA GeForce RTX 4090.

## Prerequisites

1. Install Nix with flakes enabled:

   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

1. Enable flakes in your Nix configuration (`~/.config/nix/nix.conf`):

   ```nix
   experimental-features = nix-command flakes
   ```

## Quick Start

1. Clone this repository:

   ```bash
   git clone <your-repo-url>
   cd yue-repro
   ```

1. Enter the development shell (or `direnv allow` if using [direnv](https://direnv.net/)):

   ```bash
   nix develop
   ```

1. Clone the YuE repository:

   ```bash
   make setup
   ```

1. Run the demo:

   ```bash
   make demo
   ```

This will:

1. Clone the YuE repository
2. Set up the required model files
3. Generate a sample music piece using the default prompts

## Project Structure

- `flake.nix` - Nix flake defining the development environment
- `Makefile` - Build automation for YuE setup and demo
- `genre.txt` - Genre tags for music generation
- `lyrics.txt` - Lyrics for music generation
- `output/` - Output directory for generated music

## Customization

1. Edit `genre.txt` to specify different musical styles
2. Edit `lyrics.txt` to provide your own lyrics
3. Modify the demo parameters in `Makefile` to adjust generation settings

## Notes

- The development environment uses Python 3.8 with CUDA support
- Flash Attention 2 is installed for optimal GPU memory usage
- The environment includes all dependencies required by YuE

## License

This build configuration is provided under the same Apache 2.0 license as YuE.
See the [YuE repository](https://github.com/multimodal-art-projection/YuE) for
more details about the model's license and usage terms.
