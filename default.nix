{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let env = bundlerEnv {
  name = "nixos-webhooks-irc-env";

  inherit ruby;
  gemdir = ./.;
};
in
stdenv.mkDerivation rec {
  name = "nixos-webhooks-irc";
  src = ./.;
  buildInputs = [
    env
  ];

  postInstall = ''
    mkdir -p $out/lib
    cp *.rb $out/lib/
  '';
}
