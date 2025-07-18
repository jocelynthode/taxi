{ lib, makeWrapper, python3, fetchFromGitHub, ... }:
let
  withPlugins = pluginsFunc:
    let plugins = pluginsFunc availablePlugins;
    in python3.pkgs.buildPythonPackage {
      name = "${taxi.name}-with-plugins";
      inherit (taxi) version meta;
      format = "other";

      nativeBuildInputs = [ makeWrapper ];
      propagatedBuildInputs = plugins ++ taxi.propagatedBuildInputs;

      installPhase = ''
        makeWrapper ${taxi}/bin/taxi $out/bin/taxi \
          --prefix PYTHONPATH : "${taxi}/${python3.sitePackages}:$PYTHONPATH"
      '';

      doCheck = false;
      dontUnpack = true;
      dontBuild = true;

      passthru = taxi.passthru // {
        withPlugins = morePlugins: withPlugins (morePlugins ++ plugins);
      };
    };

  taxi = python3.pkgs.buildPythonPackage rec {
    pname = "taxi";
    version = "6.3.1";

    # Using GitHub instead of PyPI because tests are not distributed on the PyPI releases
    src = fetchFromGitHub {
      owner = "sephii";
      repo = pname;
      rev = version;
      hash = "sha256-QB88RpgzrQy7DGeRdMHC2SV5Esp/r5LZtlaY5C8vJxw=";
    };

    format = "pyproject";

    propagatedBuildInputs =
      [ python3.pkgs.click python3.pkgs.appdirs ];

    nativeBuildInputs = [ python3.pkgs.flit-core ];

    nativeCheckInputs = [ python3.pkgs.pytestCheckHook python3.pkgs.freezegun ];

    passthru = { inherit withPlugins availablePlugins; };

    meta = {
      homepage = "https://github.com/sephii/taxi";
      description = "Timesheeting made easy";
      license = lib.licenses.wtfpl;
    };
  };

  taxiZebra = python3.pkgs.buildPythonPackage rec {
    pname = "taxi_zebra";
    version = "5.0.0";

    src = fetchFromGitHub {
      owner = "liip";
      repo = "taxi-zebra";
      rev = version;
      sha256 = "sha256-vwlCdeWvbmoKYdEwKVmBkQTokOY4MGaxnOU3t0CRDS4=";
    };

    format = "pyproject";
    buildInputs = [ taxi ];
    nativeBuildInputs = [ python3.pkgs.setuptools python3.pkgs.wheel ];
    propagatedBuildInputs = [ python3.pkgs.requests python3.pkgs.click ];

    meta = {
      homepage = "https://github.com/liip/taxi-zebra";
      description = "Zebra backend for the Taxi timesheeting application";
      license = lib.licenses.wtfpl;
    };
  };

  taxiClockify = python3.pkgs.buildPythonPackage rec {
    pname = "taxi_clockify";
    version = "1.5.0";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-ujdacSOw7R0fNAk8ekiERNf90vg1Sk3ti8gbx4YqZFU=";
    };

    format = "pyproject";

    buildInputs = [ taxi ];

    nativeBuildInputs = [ python3.pkgs.flit-core ];

    propagatedBuildInputs = [ python3.pkgs.requests python3.pkgs.arrow ];

    meta = {
      homepage = "https://github.com/sephii/taxi-clockify";
      description = "Clockify backend for the Taxi timesheeting application";
      license = lib.licenses.wtfpl;
    };
  };

  taxiPetzi = python3.pkgs.buildPythonPackage rec {
    pname = "taxi_petzi";
    version = "1.1.0";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-m76pDp6/noJ05MgNJf+yFxD+TAqoFnTwhFTHSclcLxo=";
    };

    format = "pyproject";

    buildInputs = [ taxi ];

    nativeBuildInputs = [ python3.pkgs.flit-core ];

    nativeCheckInputs = [ python3.pkgs.pytestCheckHook ];

    propagatedBuildInputs = [
      python3.pkgs.google-auth-oauthlib
      python3.pkgs.google-auth-httplib2
      python3.pkgs.google_api_python_client
    ];

    meta = {
      homepage = "https://github.com/sephii/taxi-petzi";
      description = "Petzi backend for the Taxi timesheeting application";
      license = lib.licenses.wtfpl;
    };
  };

  availablePlugins = {
    zebra = taxiZebra;
    petzi = taxiPetzi;
    clockify = taxiClockify;
  };
in
  taxi
