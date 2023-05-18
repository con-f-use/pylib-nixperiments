{ lib
, buildPythonPackage
, pythonOlder
, setuptools
}:

buildPythonPackage rec {
  pname = "mypylib"; # *
  version = "1.0.0"; # *
  format = "pyproject";  # could be autodetected

  src = ./mypylib;

  nativeBuildInputs = [ setuptools ]; # *

  disabled = pythonOlder "3.7";
  pythonImportsCheck = [ "mypylib" ];

  meta = with lib; {
    description = "Minimal example library"; # *
    homepage = "https://github.com/tweag/nix-hour/tree/master/29"; # *
    license = with licenses; [ mpl20 ];  # *
    maintainers = [ maintainers.confus ];
  };
}

# *These are in pyproject.toml - maybe reading defaults vaules for these
# from there would be a worthwhile nix project?
