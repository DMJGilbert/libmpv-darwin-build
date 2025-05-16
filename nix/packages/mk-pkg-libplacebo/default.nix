{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix {},
  variant ? import ../../utils/default/variant.nix,
}: let
  name = "libplacebo";

  version = "6.338.2";
  # TODO: add to lock file
  # packageLock = (import ../../../packages.lock.nix).${name};
  # inherit (packageLock) version;

  callPackage = pkgs.lib.callPackageWith {inherit pkgs os arch;};
  nativeFile = callPackage ../../utils/native-file/default.nix {};
  crossFile = callPackage ../../utils/cross-file/default.nix {};
  xctoolchainLipo = callPackage ../../utils/xctoolchain/lipo.nix {};

  pname = import ../../utils/name/package.nix name;
  src = pkgs.fetchgit {
    url = "https://github.com/haasn/libplacebo.git";
    sha256 = "7NsZlJZnkV4yEznpeAnETY70tfxxqpsbNll400rm6Po=";
    rev = "64c1954570f1cd57f8570a57e51fb0249b57bb90";
    fetchSubmodules = true;
  };
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "${pname}-${os}-${arch}-${variant}-${version}";
    pname = pname;
    inherit version;
    inherit src;
    dontUnpack = true;
    enableParallelBuilding = true;
    nativeBuildInputs = [
      pkgs.git
      pkgs.meson
      pkgs.ninja
      pkgs.pkg-config
      xctoolchainLipo
    ];
    configurePhase = ''
      cd $src
      ls 3rdparty
      ls 3rdparty/glad
      cd -
      meson setup build $src \
        --native-file ${nativeFile} \
        --cross-file ${crossFile} \
        -Dvulkan=disabled -Ddemos=false \
        --prefix=$out
    '';
    buildPhase = ''
      meson compile -vC build
    '';
    installPhase = ''
      meson install -C build
    '';
  }
