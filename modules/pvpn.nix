{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "pvpn";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "YourDoritos";
    repo = "pVPN";
    rev = "v${version}";
    hash = ""; # leave blank, nix build will tell you the right hash
  };

  vendorHash = ""; # same — leave blank first time

  subPackages = [ "cmd/pvpnd" "cmd/pvpn" "cmd/pvpnctl" ]; # verify against actual repo layout

  meta = with lib; {
    description = "Proton VPN client for Linux with terminal UI, WireGuard & Stealth protocol";
    homepage = "https://github.com/YourDoritos/pVPN";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
