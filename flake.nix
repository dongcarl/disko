{
  description = "Disko - declarative disk partitioning";

  # don't lock to give precedence to a USB live-installer's registry
  inputs.nixpkgs.url = "nixpkgs";

  outputs = { self, nixpkgs, ... }: let
    supportedSystems = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    nixosModules.disko = import ./module.nix;
    lib = import ./. {
      inherit (nixpkgs) lib;
    };
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      disko = pkgs.callPackage ./package.nix {};
      default = self.packages.${system}.disko;
    });
    # TODO: disable bios-related tests on aarch64...
    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      # Run tests: nix flake check -L
      import ./tests {
        inherit pkgs;
        makeTest = import (pkgs.path + "/nixos/tests/make-test-python.nix");
        eval-config = import (pkgs.path + "/nixos/lib/eval-config.nix");
      });
  };
}