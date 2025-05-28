{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix {},
}: let
  name = "libsrt";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;
  oses = import ../../utils/constants/oses.nix;

  callPackage = pkgs.lib.callPackageWith {inherit pkgs os arch;};
  nativeFile = callPackage ../../utils/native-file/default.nix {};
  crossFile = callPackage ../../utils/cross-file/default.nix {};

  mbedtls = callPackage ../mk-pkg-mbedtls/default.nix {};

  pname = import ../../utils/name/package.nix name;
  src = callPackage ../../utils/fetch-tarball/default.nix {
    name = "${pname}-source-${version}";
    inherit (packageLock) url sha256;
  };
  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}" {} ''
    cp -r ${src} src
    export src=$PWD/src
    chmod -R a+rwx $src

    cd $src
    patch -p1 --verbose --ignore-whitespace <${../../../patches/libsrt-remove-brew-dep.patch}
    cd -

    cp ${./meson.build} $src/meson.build
    cp ${./meson.options} $src/meson.options

    cp -r $src $out
  '';
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "${pname}-${os}-${arch}-${version}";
    pname = pname;
    inherit version;
    src = patchedSource;
    dontUnpack = true;
    enableParallelBuilding = true;
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.meson
      pkgs.ninja
      pkgs.pkg-config
    ];
    buildInputs = [
      mbedtls
    ];
    configurePhase = ''
      if [ "${os}" == "${oses.macos}" ]; then
        meson setup build $src \
          --native-file ${nativeFile} \
          --cross-file ${crossFile} \
          -Dtargetos=macos \
          --prefix=$out
      else
        meson setup build $src \
          --native-file ${nativeFile} \
          --cross-file ${crossFile} \
          -Dtargetos=ios \
          --prefix=$out
      fi
    '';
    buildPhase = ''
      meson compile -vC build $(basename $src)
    '';
    installPhase = ''
      meson install -C build
    '';
  }
