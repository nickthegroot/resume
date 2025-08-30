{
  description = "Resume for @nickthegroot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        render-pdf = pkgs.writeShellScriptBin "renderPdf" ''
          set -euo pipefail
          if [ $# -ne 1 ]; then
            echo "Usage: renderPdf <file.tex>"
            exit 1
          fi

          ${pkgs.texlive.combined.scheme-full}/bin/pdflatex -interaction=nonstopmode "$1"
        '';
      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "resume-public";
            version = "1.0";
            src = ./src;
            nativeBuildInputs = [ render-pdf ];
            buildPhase = ''
              mkdir -p $out
              renderPdf resume_public.tex
            '';
            installPhase = ''
              mv resume_public.pdf $out/
            '';
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            render-pdf
          ];

          shellHook = ''
            echo "Run 'renderPdf resume_{name}.tex' to compile a resume."
            cd src/
          '';
        };
      }
    );
}
