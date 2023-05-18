{ lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
  virtualisation = {
    memorySize = 1024;
    graphics = false;
  };
  security.sudo.wheelNeedsPassword = false;
  users.mutableUsers = false;
  users.users.root.password = "";
  users.users.nixos = {
    isNormalUser = true;
    password = "";
    extraGroups = [ "wheel" ];
  };
  system.stateVersion = "23.05";
}
