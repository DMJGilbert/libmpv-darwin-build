{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix {},
}: let
  name = "libsrt";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;

  callPackage = pkgs.lib.callPackageWith {inherit pkgs os arch;};
  nativeFile = callPackage ../../utils/native-file/default.nix {};
  crossFile = callPackage ../../utils/cross-file/default.nix {};
  xctoolchainInstallNameTool = callPackage ../../utils/xctoolchain/install-name-tool.nix {};

  mbedtls = callPackage ../mk-pkg-mbedtls/default.nix {};

  pname = import ../../utils/name/package.nix name;
  src = callPackage ../../utils/fetch-tarball/default.nix {
    name = "${pname}-source-${version}";
    inherit (packageLock) url sha256;
  };
  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}" {} ''
    cp -r ${src} src
    export src=$PWD/src
    chmod -R 777 $src

    cd $src
    patch -p1 --verbose --ignore-whitespace <${../../../patches/libsrt-remove-brew-dep.patch}
    sed -i "s|/usr/bin/tclsh|${pkgs.tcl}/bin/tclsh|g" "$src/configure"
    cd -

    cp ${./meson.build} $src/meson.build

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
      pkgs.tcl
      xctoolchainInstallNameTool
    ];
    buildInputs = [
      mbedtls
    ];
    configurePhase = ''
      meson setup build $src \
        --native-file ${nativeFile} \
        --cross-file ${crossFile} \
        --prefix=$out
    '';
    buildPhase = ''
      meson compile -vC build $(basename $src)
    '';
    installPhase = ''
      meson install -C build
    '';
  }
