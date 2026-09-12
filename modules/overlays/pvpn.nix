final: prev:

{
  pvpn = prev.buildGoModule rec {
    pname = "pvpn";
    version = "0.2.6";

    src = prev.fetchFromGitHub {
      owner = "YourDoritos";
      repo = "pVPN";
      rev = "v${version}";
      hash = "sha256-BN8N+A1GIgFfnhAEZ1YgnfSW3/XYg15mYCwO+M2GBmk=";
    };

    vendorHash = "sha256-2iy3oRJuFcnBok/Pks9dSdq8ulbOpVW5D4aHawmqZmg=";

    subPackages = [ "cmd/pvpnd" "cmd/pvpn" "cmd/pvpnctl" ];

    meta = with prev.lib; {
      description = "Proton VPN client for Linux — TUI, WireGuard & Stealth protocol";
      homepage = "https://github.com/YourDoritos/pVPN";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
}
