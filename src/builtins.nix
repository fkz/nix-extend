{ stdenv, nix, perl }:

let src = stdenv.mkDerivation {
      name = "nix-source";
      phases = "unpackPhase installPhase";
      src = nix.src;
      installPhase = ''
        cp -R . $out
      '';
    }; in
stdenv.mkDerivation {
  name = "primops.nix-${builtins.readFile (src + "/version")}";
  phases = "buildPhase";
  buildInputs = [perl];
  buildPhase = ''
    echo '{' > $out
    perl -n -e '
      if (m/addPrimOp\("(.*?)", (\d), .*\)/) {
        print "   \"$1\" = $2;\n";
      }
      if (m/addConstant\("(.*?)",.*\)/) {
        print "   \"$1\" = 0;\n";
      }' \
      ${src}/src/libexpr/primops.cc >> $out
    echo '}' >> $out
  '';
}
