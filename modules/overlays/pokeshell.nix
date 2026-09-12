final: prev:

{
  pokeshell = prev.stdenv.mkDerivation rec {
    pname = "pokeshell";
    version = "unstable-2024-11-24";
    src = prev.fetchFromGitHub {
      owner = "acxz";
      repo = "pokeshell";
      rev = "6c9e2569843b08db14a964951f17a3943fd89fa2";
      hash = "sha256-PgOnzOpEM1a0jLyHYOM3+fLsjrwlK0kGPa7fi+i6qlQ="; 
    };

    nativeBuildInputs = [ prev.makeWrapper ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r bin $out/
      cp -r share $out/

      wrapProgram $out/bin/pokeshell \
        --prefix PATH : ${prev.lib.makeBinPath [
          prev.curl
          prev.jq
          prev.imagemagick
          prev.chafa
          prev.timg
        ]}

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "A featureful shell program to show pokemon sprites in the terminal";
      homepage = "https://github.com/acxz/pokeshell";
      license = licenses.gpl3Only;
      platforms = platforms.unix;
      mainProgram = "pokeshell";
    };
  };
}
