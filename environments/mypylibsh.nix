{ pkgs, ... }:
pkgs.mkShell rec {
  name = "mypylibsh";

  buildInputs = with pkgs; [
    (python3.withPackages (ps: with ps; [
      mypylib
    ]))
    uses_myPyLib
  ];

  shellHook = ''
    echo "Activated ${name}." 1>&2
    python -c "import mypylib; mypylib.cli()"
  '';
}

