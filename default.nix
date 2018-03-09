{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation rec {
  name = "nixos-webhooks-irc";
  buildInputs = [
    bundler
  ];

  #passthru = {
  #  # Allows use of a tarball URL.
  #  release = (import ./release.nix {inherit pkgs;});
  #};
}
