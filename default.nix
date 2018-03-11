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

  installPhase = ''
    mkdir -vp $out/
    cp -vr lib $out/lib
    cp -vpr bin $out/bin
  '';
}
