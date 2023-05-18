{ pkgs, self, ... }: {
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      mypylib
    ]))
    self.packages.uses_myPyLib # we could use an overlay here, too
  ];
}
