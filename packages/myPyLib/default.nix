{ lib
, buildPythonPackage
, pythonOlder
, setuptools
}:

buildPythonPackage rec {
  pname = "mypylib";
  version = "1.0.0";
  format = "pyproject";

  src = ./mypylib;

  nativeBuildInputs = [ setuptools ];

  disabled = pythonOlder "3.7";
  pythonImportsCheck = [ "mypylib" ];

  meta = with lib; {
    description = "Minimal example library";
    homepage = "https://github.com/tweag/nix-hour/tree/master/29";
    license = with licenses; [ mpl20 ];
    maintainers = [ maintainers.confus ];
  };
}
