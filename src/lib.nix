{ lib, ... }: rec {
  builtinName = name: lib.removePrefix "__" name;
  normalName = name:
    assert !lib.hasPrefix "__" name;
    if builtins.elem name builtinsWithoutHiding then name else "__" + name;
  overrideBuiltins = overrides:
      let self = builtins //
            lib.mapAttrs' (name: value: lib.nameValuePair (builtinName name) value)
            allOverrides;
          currentScopedImport =
            if overrides ? scopedImport
            then overrides.scopedImport
            else scopedImport;
          allOverrides = overrides // {
            builtins = self;
            import = self.scopedImport {};
            scopedImport = x: currentScopedImport (self // x);
          };
      in self;

  # it would be better if we could get them directly from nix somehow
  builtinsWithoutHiding = [
    "builtins"
    "true" "false" "null"
    "scopedImport" "import"
    "isNull" "abort" "throw" "baseNameOf" "dirOf" "removeAttrs" "map"
    "toString" "derivationStrict" "fetchTarball" "derivation"
  ];
  unpureBuiltins = [
    "__currentTime"
    "__currentSystem"
    #"__nixVersion"
    "__storeDir"
    #TODO add the rest
  ];
  importWithOverrides = overrides: path: scopedImport (overrideBuiltins overrides) path;

  dontAllowUnpure = builtins.listToAttrs (map (name: { inherit name; value = throw "${name} is unpure and thus not allowed inside this file"; }) unpureBuiltins);
}
