{
  description = "ltspice";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      wrapWine = ((import ./wrapWine.nix) {inherit pkgs;}).wrapWine;
      installer = builtins.fetchurl {
        url = "https://ltspice.analog.com/software/LTspice64.msi";
        sha256 = "sha256:0zwq3s505pn11f8djsi8yb0kf1vswqx99r5lk5yxy377dy8zg4xg";
      };
      wine = pkgs.wineWowPackages.stagingFull;
      ltspice_bin = wrapWine {
        wine = wine;
        name = "LTspice";
        is64bits = true;
        executable = "$WINEPREFIX/drive_c/Program Files/ADI/LTSpice/LTSpice.exe";
        firstrunScript = ''
          pushd "$WINEPREFIX/drive_c"
            ${wine}/bin/wine msiexec /q /i ${installer}
          popd
        '';
      };
      ltspice_desktop = pkgs.makeDesktopItem {
        name = "LTspice";
        desktopName = "LTspice";
        type = "Application";
        exec = "${ltspice_bin}/bin/LTspice";
      };
      ltspice = pkgs.symlinkJoin {
        name = "LTspice";
        paths = [
          ltspice_bin
          ltspice_desktop
        ];
      };
    in {
      packages = {
        ltspice = ltspice;
        default = ltspice;
      };
    });
}
