{ pkgs, stdenv, lib }:

stdenv.mkDerivation {
  pname = "uses_myPyLib";
  version = "1.0";

  propagatedBuildInputs = [
    (pkgs.python3.withPackages (p: with p; [ mypylib ]))
  ];
  dontUnpack = true;
  installPhase = "install -Dm755 ${./uses_mypylib.py} $out/bin/uses-mypylib";
  doInstallCheck = true;
  installCheckPhase = ''$out/bin/uses-mypylib > /dev/null'';

  meta = with lib; {
    description = "Example python executable";
    homepage = "https://github.com/tweag/nix-hour/tree/master/29";
    license = licenses.mpl20;
    maintainers = [ maintainers.confus ];
  };
}

