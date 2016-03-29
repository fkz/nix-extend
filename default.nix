{ nixpkgs ? import <nixpkgs> {},
  lib ? nixpkgs.lib,
  nix ? nixpkgs.nix,
  builtinInformation ? import (nixpkgs.callPackage ./src/builtins.nix {})
}
import ./src/lib.nix { inherit lib builtinInformation; }
