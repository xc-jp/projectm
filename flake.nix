{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };
  outputs = inputs:
    let
      system = "x86_64-darwin";
      pkgs = import inputs.nixpkgs {
        inherit system;
        crossSystem = {
          config = "aarch64-apple-ios";
          sdkVer = "16.1";
          useiOSPrebuilt = true;
          xcodePlatform = "iPhoneOS";
          xcodeVer = "14.2";
        };
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [
          (final: prev: {
            xcode = final.xcode_14_2;
            buildPackages = prev.buildPackages // {
              darwin = prev.buildPackages.darwin // {
                xcode = final.buildPackages.darwin.xcode_14_2;
                xcode_14_2 = final.buildPackages.requireFile rec {
                  name = "Xcode.app";
                  hashMode = "recursive";
                  sha256 = "18hxjgcqsydmky7ppfnx7j7g9dg0g1hkfi11rwqvm7gklf5xs1z6";
                  message = "Download Xcode 14.2 from Apple";
                };
              };
            };
            darwin = prev.darwin // {
              xcode = final.darwin.xcode_14_2;
              xcode_14_2 = final.requireFile rec {
                name = "Xcode.app";
                hashMode = "recursive";
                sha256 = "18hxjgcqsydmky7ppfnx7j7g9dg0g1hkfi11rwqvm7gklf5xs1z6";
                message = "Download Xcode 14.2 from Apple";
              };
            };
          })
        ];
      };
      projectm = pkgs.stdenv.mkDerivation {
        name = "projectm";
        src = ./.;
        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.autoreconfHook
          pkgs.which
        ];

        buildInputs = [
          #pkgs.SDL2
          #pkgs.qtdeclarative
          #pkgs.libpulseaudio
          #pkgs.glm
        ];

      };
    in
    {
      legacyPackages.${system} = pkgs;
      packages.${system} = {
        default = projectm;
      };
    };
}
