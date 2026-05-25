{
  description = "VS Code standalone CLI (code tunnel)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.121.0";
      commit = "f6cfa2ea2403534de03f069bdf160d06451ed282";

      sources = {
        aarch64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_arm64_cli.tar.gz";
          hash = "sha256-BcDI6flgSXYg7WxUueDX3tY76EJsbnHoXorZA/hPPaM=";
        };
        x86_64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_x64_cli.tar.gz";
          hash = "sha256-fLDSocQVlqqTzqi1D5MuNPzUdgz9K70aAHwfVjgbk+c=";
        };
        aarch64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_arm64_cli.zip";
          hash = "sha256-DgLWHxBBhl6jGxu8MHu6HuhVn+ZRw55P1XJ2wocacCs=";
        };
        x86_64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_x64_cli.zip";
          hash = "sha256-+GBOdDK0WWQVMu+UjkuYGoVefQIuKCiw9gdP2cRY/KI=";
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
