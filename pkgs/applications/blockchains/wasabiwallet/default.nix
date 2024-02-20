{ lib, stdenv
, autoPatchelfHook
, makeWrapper
, fetchurl
, makeDesktopItem
, lttng-ust_2_12
, fontconfig
, openssl
, xorg
, zlib
}:

let
  # These libraries are dynamically loaded by the application,
  # and need to be present in LD_LIBRARY_PATH
  runtimeLibs = [
    fontconfig.lib
    openssl
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libICE
    xorg.libSM
    zlib
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wasabiwallet";
  version = "2.0.5";

  src = fetchurl {
    url = "https://github.com/zkSNACKs/WalletWasabi/releases/download/v${finalAttrs.version}/Wasabi-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-1AgX+Klw/IsRRBV2M1OkLGE4DPqq6hX2h72RNzad2DM=";
  };

  dontBuild = true;

  desktopItem = makeDesktopItem {
    name = "wasabi";
    exec = "wasabiwallet";
    desktopName = "Wasabi";
    genericName = "Bitcoin wallet";
    comment = finalAttrs.meta.description;
    categories = [ "Network" "Utility" ];
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = runtimeLibs ++ [
    lttng-ust_2_12
  ];

  installPhase = ''
    mkdir -p $out/opt/${finalAttrs.pname} $out/bin $out/share/applications
    cp -Rv . $out/opt/${finalAttrs.pname}

    makeWrapper "$out/opt/${finalAttrs.pname}/wassabee" "$out/bin/${finalAttrs.pname}" \
      --suffix "LD_LIBRARY_PATH" : "${lib.makeLibraryPath runtimeLibs}"

    makeWrapper "$out/opt/${finalAttrs.pname}/wassabeed" "$out/bin/${finalAttrs.pname}d" \
      --suffix "LD_LIBRARY_PATH" : "${lib.makeLibraryPath runtimeLibs}"

    cp -v $desktopItem/share/applications/* $out/share/applications
  '';

  meta = with lib; {
    description = "Privacy focused Bitcoin wallet";
    homepage = "https://wasabiwallet.io/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ mmahut ];
  };
})
