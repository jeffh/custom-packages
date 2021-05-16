{ stdenv, lib, fetchurl, openjdk, rlwrap, makeWrapper, maintainers }:

let
  host = stdenv.hostPlatform;
  platform = if host.isDarwin then "macos"
             else if host.isBSD then "freebsd"
             else if host.isLinux then "linux"
             else throw "unsupported platform";

  # Values are provided on https://ziglang.org/download/
  platformSha256 = if host.isDarwin then (
                     if host.isx86_64 then "eaa331bb172803852aa1c37cc2ebe12648283022bfe05fdb3e6511640109af04"
                     else if stdenv.hostPlatform.isAarch64 then "f9fbbdb2895882679ed6abf3e232a0820ca7f99c1b3e2fb11ba8fb215347d54e"
                     else throw "unsupported architecture on macOS"
                   ) else if host.isBSD then (
                     if host.isx86_64 then "9cdc5360eb4d8c8722556fb812815b69a3c1459ef2cc32f98d0c6627c1fbba0e"
                     else throw "unsupported architecture on BSD"
                   ) else if host.isLinux then (
                     if host.isx86_64 then "b1625d34ea8594a74f431dd773b2acf2cba8913e68412bd6436d581fc7c16e45"
                     else if stdenv.hostPlatform.isAarch64 then "e0cb7104c50ca9f5beff1db488dff589a2828164568fa9039706cdb63a8538eb"
                     else throw "unsupported architecture on linux"
                   ) else throw "unsupported platform";

in
stdenv.mkDerivation rec {
    pname = "zig-master";
    version = "0.8.0-dev.2272+d98e39fa6"; # See url of at https://ziglang.org/download/

    src = fetchurl {
      url = "https://ziglang.org/builds/zig-${platform}-${stdenv.hostPlatform.qemuArch}-${version}.tar.xz";
      sha256 = "${platformSha256}";
    };

    buildInputs = [ makeWrapper ];

    installPhase = let
        binPath = lib.makeBinPath [ rlwrap ];
    in
      ''
        mkdir -p $prefix/lib

        cp -r lib/zig $prefix/lib

        install -Dt $out/bin zig
        wrapProgram $out/bin/zig --prefix PATH : $out/bin:${binPath}
    '';


    meta = {
        description = "The Zig Programming Language (version ${version})";
        homepage = https://ziglang.org/;
        license = lib.licenses.mit;
        platforms = lib.platforms.unix;
        maintainers = [ maintainers.jeffh ];
    };
}

