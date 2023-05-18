{

  description = "Example for Python Libraries as overlays and their usage";

  outputs = { self, nixpkgs }: # implicitly get `nixpkgs` from flake registry
    let
      system = "x86_64-linux";  # for simplicity, don't want to deal with flake-utils now

      overlayed-nixpkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.customPyLibs self.overlays.pkgsOverlay ];
      };
    in
    {

      overlays = {
        myPyLibOverlay = final: prev: {
          mypylib = final.callPackage ./packages/myPyLib { };
        };

        # Accumulate the Python overlays and make them available
        # for all python interpreters via pythonWithPackages
        customPyLibs = final: prev: {
          # pythonPackagesExtensions (PR #91850) merged Aug 6, 2022
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            self.overlays.myPyLibOverlay
          ];
        };

        pkgsOverlay = _: _: self.packages."${system}";
      };

      packages."${system}" = {
        # `nix build './#uses_myPyLib'`
        uses_myPyLib = overlayed-nixpkgs.callPackage ./packages/uses_myPyLib { };
      };

      apps."${system}" = {
        # `nix run './#useMyPyLib'` should give you output
        useMyPyLib = {
          type = "app";
          program = "${self.packages."${system}".uses_myPyLib}/bin/uses-mypylib";
        };
      };

      devShells."${system}" = {
        # `nix develop`
        default = self.devShells."${system}".mypylibsh;
        # `nix develop ./#mypylibsh`
        mypylibsh = overlayed-nixpkgs.callPackage ./environments/mypylibsh.nix { };
      };

      nixosModules = {
        mypylibModule = import ./modules/mypylibModule.nix;
      };

      nixosConfigurations = {
        # `nixos-rebuild build-vm --flake './#someMachine'`
        someMachine = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            # different way to use the overlay, if you don't like the
            # `import nixpkgs` above in line 11
            { nixpkgs.overlays = [ self.overlays.customPyLibs ]; }
            ./machines/common.nix
            ./machines/some/configuration.nix
          ];
        };

        # `nixos-rebuild build-vm --flake './#sameMachine'`
        # Is there a way to use nix features only?
        # `nisos-rebuild` only exists on NixOS, and not on normal nix 
        # installations?
        sameMachine = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            self.nixosModules.mypylibModule
            { config.programs.mypylibModule.enable = true; }
            ./machines/common.nix
          ];
        };
      };

      # `nix fmt`
      formatter."${system}" = nixpkgs.legacyPackages."${system}".nixpkgs-fmt;

      checks."${system}" = {
        default = nixpkgs.legacyPackages."${system}".nixosTest {
          name = "mypylib default test";
          nodes = {
            machine = {
              imports = [ ./modules/mypylibModule.nix ];  # but howto pass self or the overlay?
              programs.mypylibModule.enable = true;
              users.users.nixos = {
                isNormalUser = true;
                initialPassword = "";
              };
            };
          };
          testScript = ''
            start_all()

            machine.wait_for_unit("multi-user.target")
            machine.succeed("python -c 'import mypylib'")
            machine.succeed("uses-mypylib")
          '';
        };
      };

    # hydraJobs = ...;
    # templates = ...;

    };

    nixConfig = {
      bash-prompt-prefix = "pylib-nixperiments";
      # trusted-substituters, trusted-public-keys, builders-use-substitutes, ...
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html
    };
}
