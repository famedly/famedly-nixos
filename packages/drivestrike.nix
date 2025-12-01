{
  fetchurl,
  stdenv,
  lib,
  autoPatchelfHook,
  dmidecode,
  glib,
  glib-networking,
  libsoup_2_4,
  rpmextract,
  wrapGAppsHook3,

  writers,
  common-updater-scripts,
  nvchecker,
}:
let
  insecureLibSoup = libsoup_2_4.overrideAttrs (drv: {
    meta = drv.meta // {
      # This allows using libsoup as a dependency; since we're
      # building our packages from a flake-imported nixpkgs, there is
      # no better way to do this. To still propagate this to the
      # package evaluation, we inherit these CVEs on our
      # `drivestrike`.
      #
      # Yes, there's not much we can do besides using an insecure
      # library.
      #
      # FWIW, debian-based systems *also* install an insecure version
      # of libsoup, it's just hidden from them because it's shipped
      # alongside drivestrike in their apt repo.
      #
      # Shipping insecure dependencies and just not telling anyone is
      # pretty common in the proprietary application world, sadly.
      #
      # TODO: Remove this entire override if/when drivestrike stop
      # using libsoup 2.4.
      knownVulnerabilities = [ ];
    };
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "drivestrike";
  version = "2.1.23-12";
  src = fetchurl {
    url = "https://app.drivestrike.com/static/yum/drivestrike.rpm";
    sha256 = "sha256-wZ/0uD/mdJvPS+bASjwg9g79ZG+oSdwXXbyxb5rXyeo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    glib
    glib-networking
    rpmextract
  ];
  buildInputs = [ insecureLibSoup ];

  unpackCmd = ''
    mkdir ${finalAttrs.pname}-${finalAttrs.version} && pushd ${finalAttrs.pname}-${finalAttrs.version}
    rpmextract $curSrc
    popd
  '';

  postPatch = ''
    substituteInPlace lib/systemd/system/drivestrike.service \
      --replace "/usr/bin/drivestrike" "$out/bin/drivestrike"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ dmidecode ]}
    )
  '';

  installPhase = ''
    install -D usr/bin/drivestrike $out/bin/drivestrike
    install -D lib/systemd/system/drivestrike.service $out/lib/systemd/system/drivestrike.service
  '';

  passthru.updateScript =
    writers.writeNuBin "update-drivestrike"
      {
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [
            common-updater-scripts
            nvchecker
          ])
        ];
      }
      ''
        let scratch_dir = (mktemp --directory nvchecker.XXXXXX)
        let config = $scratch_dir + '/config.toml'

        {
          drivestrike: {
            source: "apt"
            pkg: "drivestrike"
            mirror: "https://app.drivestrike.com/static/apt/"
            suite: "stretch"
          }
        } | to toml | save --force $config

        let version = (nvchecker --logger json --file $config |
          from json --objects |
          where event == updated and name == drivestrike |
          get 0.version)

        rm -r $scratch_dir

        update-source-version drivestrike $version
      '';

  meta.knownVulnerabilities = [
    ''
      We depend on libsoup 2, which is EOL, and has many known, unfixed CVEs.

      See the upstream libsoup vulnerability list for details.
    ''
  ];
})
