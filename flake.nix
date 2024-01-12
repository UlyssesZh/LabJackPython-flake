{
  description = "LabJackPython is our cross-platform Python module for communicating with the LabJack U3, U6, UE9, and U12";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    exodriver.url = "github:UlyssesZh/exodriver-flake";
    LabJackPython-pip = {
      url = "github:labjack/LabJackPython/2.1.0";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, exodriver, LabJackPython-pip }: let
    version = "2.1.0";
    supportedSystems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
  in {
    packages = forAllSystems (system: let
      exo = exodriver.packages.${system}.exodriver;
      buildPythonPackage = nixpkgsFor.${system}.python3Packages.buildPythonPackage;
      substituteAll = nixpkgsFor.${system}.substituteAll;
    in rec {
      LabJackPython = buildPythonPackage rec {
        pname = "LabJackPython";
        inherit version;
        src = LabJackPython-pip;
        propagatedBuildInputs = [ exo ];
        pythonImportsCheck = [ "LabJackPython" "Modbus" "u3" "u6" "u12" "ue9" ];
        patches = [
          (substituteAll {
            src = ./lib-path.patch;
            liblabjackusb = "${exo.out}/lib/liblabjackusb.so";
          })
        ];
      };
      default = LabJackPython;
    });
    nixosModules.LabJackPython = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.LabJackPython ];
      services.udev.packages = [ pkgs.exodriver ];
    };
    checks = forAllSystems (system: with nixpkgsFor.${system}; rec {
      inherit (self.packages.${system}) LabJackPython;
      test = stdenv.mkDerivation {
        pname = "check-LabJackPython";
        inherit version;
        src = ./.;
        buildInputs = [ LabJackPython python3 ];
        buildPhase = ''
          python test.py
        '';
        installPhase = ''
          mkdir -p $out
        '';
      };
    });
    devShell = forAllSystems (system: nixpkgsFor.${system}.mkShell (let
      LabJackPython = self.packages.${system}.LabJackPython;
      python3 = nixpkgsFor.${system}.python3;
    in rec {
      packages = [ LabJackPython python3 ];
    }));
  };
}
