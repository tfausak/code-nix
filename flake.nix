{
  description = "VS Code standalone CLI (code tunnel)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.120.0";
      commit = "0958016b2af9f09bb4257e0df4a95e2f90590f9f";

      sources = {
        aarch64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_arm64_cli.tar.gz";
          hash = "sha256-pFGcRoGOtCNeT4u0V19ja4SKS9wulWKLS5VgMm2AB2s=";
        };
        x86_64-linux = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_alpine_x64_cli.tar.gz";
          hash = "sha256-JNujZgmIqFpXXYI3YYiU5sC8AvyZMk3u3YxySBpNjpk=";
        };
        aarch64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_arm64_cli.zip";
          hash = "sha256-tAkb8EtnB6mOcIjaUds15pu6CgTmFtPEEE5F4Xa5R+8=";
        };
        x86_64-darwin = {
          url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/${commit}/vscode_cli_darwin_x64_cli.zip";
          hash = "sha256-PudBtb3QJ3mhTJBzmDeCn0pfovJPdOZdxWsEoxn5CJA=";
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
