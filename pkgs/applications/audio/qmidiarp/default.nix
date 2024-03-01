{ lib, stdenv
, fetchgit
, autoreconfHook
, lv2
, pkg-config
, qt5
, alsa-lib
, libjack2
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qmidiarp";
  version = "0.7.0";

  src = fetchgit {
    url = "https://git.code.sf.net/p/qmidiarp/code";
    sha256 = "sha256-oUdgff2xsXTis+C2Blv0tspWNIMGSODrKxWDpMDYnEU=";
    rev = "qmidiarp-${finalAttrs.version}";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    lv2
    libjack2
  ] ++ (with qt5; [
    qttools
  ]);

  meta = with lib; {
    description = "An advanced MIDI arpeggiator";
    longDescription = ''
      An advanced MIDI arpeggiator, programmable step sequencer and LFO for Linux.
      It can hold any number of arpeggiator, sequencer, or LFO modules running in
      parallel.
    '';

    homepage = "https://qmidiarp.sourceforge.net";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ sjfloat ];
  };
})
