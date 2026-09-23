{
  description = "VS Code standalone CLI (code tunnel)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.138.0";
      commit = "7debcd0e2acdea1c52de81bf9ee1620444407dda";

      sources = {
        aarch64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_arm64_cli.tar.gz";
          hash = "sha256-BFMCNqdL71m/TidRodQul1/ujTqAuxK4BJs4MEgr9PM=";
        };
        x86_64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_x64_cli.tar.gz";
          hash = "sha256-gd3iJH4QxlHyS44YfWnpU5+NUiYm98lLklogU4STb1Y=";
        };
        aarch64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_arm64_cli.zip";
          hash = "sha256-E+Wfy8jjnnShfodZTi6eCyuRaPwUXy7S4quTBnEZC9A=";
        };
        x86_64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_x64_cli.zip";
          hash = "sha256-peCZFRRfY6dK76UY/gzdAVClsPrwGPiaqJSGbIKdccc=";
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
