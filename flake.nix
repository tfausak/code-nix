{
  description = "VS Code standalone CLI (code tunnel)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.131.0";
      commit = "e4c7e7b1d6d060162f4aa7f8225271b67ce1df75";

      sources = {
        aarch64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_arm64_cli.tar.gz";
          hash = "sha256-gm2QdD7ih1rAREhdXjwva6RL356xlXusedOI6MiC3UM=";
        };
        x86_64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_x64_cli.tar.gz";
          hash = "sha256-S30WtX5sxd48jS0/3CleNFPgZwW4jb4V5A0bavypCE0=";
        };
        aarch64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_arm64_cli.zip";
          hash = "sha256-8TVthHXoFHEWX6FM8UbDeJkk3FxQB+1Rj4JuZ98FEC4=";
        };
        x86_64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_x64_cli.zip";
          hash = "sha256-DTzR0V7qQk4mUBstQ2VEvS6k443JjmPTMRkBp988bH0=";
        };
      };

      forAllSystems = nixpkgs.lib.genAttrs (builtins.attrNames sources);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          src = pkgs.fetchurl {
            inherit (sources.${system}) url hash;
          };
          isLinux = pkgs.lib.hasSuffix "linux" system;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "vscode-cli";
            inherit version src;

            sourceRoot = ".";

            nativeBuildInputs = pkgs.lib.optionals (!isLinux) [ pkgs.unzip ];

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              install -Dm755 code $out/bin/code
            '';

            meta = {
              description = "Visual Studio Code CLI for remote tunnels";
              homepage = "https://code.visualstudio.com";
              license = pkgs.lib.licenses.unfree;
              mainProgram = "code";
              platforms = builtins.attrNames sources;
            };
          };
        }
      );
    };
}
