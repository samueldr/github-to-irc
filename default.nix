{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) bundlerEnv stdenv;

  env = bundlerEnv {
  name = "nixos-webhooks-irc-env";

  gemdir = ./.;
};
in
stdenv.mkDerivation rec {
  name = "nixos-webhooks-irc";
  src = ./.;
  buildInputs = [
    env
    env.wrappedRuby
  ];

  installPhase = ''
    mkdir -vp $out/
    cp -vr lib $out/lib
    cp -vpr bin $out/bin
  '';
}
