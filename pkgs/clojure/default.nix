{ stdenv, fetchurl, openjdk, rlwrap, makeWrapper, maintainers, pkgs }:

stdenv.mkDerivation rec {
    pname = "clojure";
    version = "1.10.3.839"; # find in example at: https://clojure.org/guides/getting_started#_installation_on_linux

    src = fetchurl {
        url = "https://download.clojure.org/install/clojure-tools-${version}.tar.gz";
        sha256 = "1rzpv934ajnhb5q6z4dqa4dy8g21465cj3q5vviqd9hfmmvibzwx";
    };

    buildInputs = [ openjdk rlwrap makeWrapper ];

    installPhase = let
        binPath = pkgs.lib.makeBinPath [ rlwrap openjdk ];
    in
      ''
        mkdir -p $prefix/libexec

        cp clojure-tools-${version}.jar $prefix/libexec
        cp {,example-}deps.edn $prefix

        substituteInPlace clojure --replace PREFIX $prefix

        install -Dt $out/bin clj clojure
        wrapProgram $out/bin/clj --prefix PATH : $out/bin:${binPath}
        wrapProgram $out/bin/clojure --prefix PATH : $out/bin:${binPath}
    '';

    installCheckPhase = ''
      CLJ_CONFIG=$out CLJ_CACHE=$out/libexec $out/bin/clojure \
        -Spath \
        -Sverbose \
        -Scp $out/libexec/clojure-tools-${version}.jar
    '';


    meta = {
        description = "The Clojure Programming Language (version ${version})";
        homepage = https://clojure.org;
        license = pkgs.lib.licenses.epl10;
        platforms = pkgs.lib.platforms.unix;
        maintainers = [ maintainers.jeffh ];
    };
}

