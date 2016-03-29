{ lib, builtinInformation, ... }: rec {

  builtinName = name: lib.removePrefix "__" name;

  normalName = name:
    assert !lib.hasPrefix "__" name;
    let candidate1 = name;
        candidate2 = "__" + name; in
    if builtinInformation ? ${candidate1} then
      candidate1
    else if builtinInformation ? ${candidate2} then
      candidate2
    else
      throw "${name} is not a builtin";

  overrideBuiltins = overrides: builtins:
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

  importWithOverrides = overrides: path: scopedImport (overrideBuiltins overrides) path;

  hideBuiltin = name: builtins:
    if !(builtinInformation ? ${name}) then
      throw "${name} is no builtin"
    else
      let arity = builtinInformation.${name}
          list = builtins.genList (x: x) arity
          altFunction = builtins.foldl' (previous z new: previous) (throw "builtin ${name} is hidden") list; in
      { ${name} = altFunction; }

  swapImports = importMapping: {
    import = x:
      if importMapping ? ${builtins.toPath x} then


  unpureBuiltins = [
   "__currentTime"
   "__currentSystem"
   "__nixVersion"
   "__storeDir"
   "__langVersion"
   "__getEnv"
   "__pathExists"
   "__readFile"
   "__readDir"
   "__findFile"
   "__filterSource"
   "fetchTarball"
   "__nixPath"
  ];

  dontAllowUnpure = lib.zipAttrsWith (name: values: builtins.head values) (map hideBuiltin unpureBuiltins);
}
