# This file has been generated by node2nix 1.7.0. Do not edit!
{ pkgs, nodejs }:

let
  nodeEnv = import ./node-env.nix {
    inherit (pkgs) stdenv python2 util-linux runCommand writeTextFile lib;
    inherit nodejs;
    libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
  };
in
import ./node-packages.nix {
  inherit (pkgs) fetchurl fetchgit;
  inherit nodeEnv;
}
