{ lib, buildEnv, writeScript, writeScriptBin, runtimeShell
, nix, cacert
, xauth
}:

let
  xauthorityPath = "/hack/Xauthority";

  refreshXauthority = writeScriptBin "refresh-xauthority" ''
    #!${runtimeShell}
    set -eu
    ${xauth}/bin/xauth -i -f /hack/host.Xauthority nlist | sed -e 's/^..../ffff/' | ${xauth}/bin/xauth -f ${xauthorityPath} nmerge -
  '';

  commonEnv = buildEnv {
    name = "env";
    paths = [
      nix
      cacert
      refreshXauthority
    ];
  };

  commonEntryScript = writeScript "entry.sh" ''
    #!${runtimeShell}
    set -eu

    ln -s /hack/X11-unix/ /tmp/.X11-unix
    ${refreshXauthority}/bin/refresh-xauthority

    sleep inf
  '';

in {
  inherit commonEnv commonEntryScript;
}
