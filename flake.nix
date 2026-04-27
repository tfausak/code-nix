{
  description = "VS Code standalone CLI (code tunnel)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.117.0";
      commit = "10c8e557c8b9f9ed0a87f61f1c9a44bde731c409";

      sources = {
        aarch64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_arm64_cli.tar.gz";
          hash = "sha256-ElaJCyQjogGz/dxVUq6QiioRnWIBUkJyUob220HVZCc=";
        };
        x86_64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_x64_cli.tar.gz";
          hash = "sha256-upj/OWd802LU1ZFtGuPQw70jnsB0XcdsO3RCFn/u/ss=";
        };
        aarch64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_arm64_cli.zip";
          hash = "sha256-/lcBGrLZHpd9Qrym+HzYAY5L1zRwxVe97x3lfcPfSLU=";
        };
        x86_64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_x64_cli.zip";
          hash = "sha256-/t3HTUqI9btRsYIMgDzNRwJSUEXOJMrl9lP5TnGHND4=";
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
