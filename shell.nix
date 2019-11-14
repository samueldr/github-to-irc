{ pkgs ? import <nixpkgs> {}
, thisDir ? toString ./.
, runDir ? thisDir + "/run"
}:

let
  github-to-irc = import ./. { inherit pkgs; };
  inherit (pkgs)
    mkShell
    writeText writeShellScript
    rabbitmq-server
    writeShellScriptBin
  ;

  rmqVars = ''
    # Though, this is unused...
    export RABBITMQ_CONFIG_FILE="${thisDir}/run/rabbitmq.conf"

    # Misc "run" directories.
    export RABBITMQ_MNESIA_BASE="${runDir}/rabbitmq/mnesia"
    export RABBITMQ_SCHEMA_DIR="${runDir}/rabbitmq/schema"
    export RABBITMQ_GENERATED_CONFIG_DIR="${runDir}/rabbitmq/config"
    export RABBITMQ_LOG_BASE="${runDir}/rabbitmq/logs"
    export RABBITMQ_NODENAME="rabbitmq-github-to-irc@$HOSTNAME"
  '';

  wrapped-rabbitmqctl = writeShellScriptBin "rabbitmqctl" ''
    ${rmqVars}

    exec ${rabbitmq-server}/bin/rabbitmqctl "$@"
  '';

  rmq-server = writeShellScript "rabbitmq-server-script" ''
    ${rmqVars}

    # To trace the server script, if it ever causes headaches again.
    # exec bash -x ${rabbitmq-server}/bin/rabbitmq-server "$@"

    exec ${rabbitmq-server}/bin/rabbitmq-server "$@"
  '';

  procfile = writeText "github-to-irc-Procfile" ''
    rabbitmq: exec ${rmq-server}
  '';
in
mkShell {
  buildInputs = github-to-irc.buildInputs ++ (with pkgs; [
    foreman
    wrapped-rabbitmqctl
  ]);

  shellHook = ''
    cat <<EOF

    github-to-irc shell
    ===================

    You can start a test environment with rabbitmq using 'start-services'.
    ihis starts a limited subset of the services needed for this bridge to
    start. The services are supervised by foreman.

    The bridge is started using 'bin/github-to-irc'.

    This is exited by interrupting the process (e.g. ^C).

    Do note that this will not start, nor configure, the bridge outright. Look
    at the README.md file for development usage.

    Have fun!

    EOF

    start-services() {
      mkdir -vp "${runDir}"
      echo ":: Starting development environment"
      exec foreman start -d "${runDir}" -f "${procfile}"
    }
  '';
}
