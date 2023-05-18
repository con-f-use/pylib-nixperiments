{ config, lib, pkgs, self, ... }:
{
  options.programs.mypylibModule.enable = lib.mkEnableOption "mypylib as module and used in an application";

  config = lib.mkIf config.programs.mypylibModule.enable {

    nixpkgs.overlays = [ self.overlays.customPyLibs ];

    environment.systemPackages = with pkgs;
      [
        (python3.withPackages (ps: with ps; [
          mypylib
        ]))
        self.packages."${system}".uses_myPyLib # we could use an overlay here, too
      ];

  };
}
