{
  description = "An example of MYBONK community full nodes configuration template.";

  # This is an example to show how it's done.

  # Pull in nix-bitcoin's flake.
  # inputs.nix-bitcoin.url = "github:fort-nix/nix-bitcoin";

  # ... Or pull in the flake of the fork of `nix-bitcoin` by Chris to use SIGNET of Mutinynet instead of MAINNET.
  # Note: When used the parameter `services.bitcoind.testnet`is disregarded, the system will use Mutinynet regardless.
  inputs.nix-bitcoin.url = "github:chrisguida/nix-bitcoin/mempool-and-fix-no-feerate";

  inputs.nixpkgs.follows = "nix-bitcoin/nixpkgs";
  inputs.nixpkgs-unstable.follows = "nix-bitcoin/nixpkgs-unstable";

  outputs = { self, nixpkgs, nix-bitcoin, ...  }:  
    let 
      # Systems we can run on (note that technically most are still being tested and may not work):
      supportedSystems = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];
      # Function to generate a set based on supported systems:
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      nixosConfigurations = {
        mybonk-jay = nix-bitcoin.inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Import the default NixOS modules from nix-bitcoin
            nix-bitcoin.nixosModules.default

            # Optional: Import secure-node and/or hardened presets
            (nix-bitcoin + "/modules/presets/secure-node.nix")
            #(nix-bitcoin + "/modules/presets/hardened.nix")
            {
              networking.hostName = "mybonk-jay";
                users.users.root = {
                  openssh.authorizedKeys.keys = [
                    # FIXME: Replace this with your SSH pubkey
                    "ssh-ed25519 AAAAC3..."
                  ];
                };
                services.clightning = {
                  extraConfig = ''
                    alias=MYBONK-SIGNET-1
                  '';
                };
              }
              ./hardware/mybonk_v4/hardware-configuration.nix
              ./configuration.nix
              ./housekeeping.nix
              ./health-check.nix
           ];
         };
         mybonk-jay2 = nix-bitcoin.inputs.nixpkgs.lib.nixosSystem {
           system = "x86_64-linux";
           modules = [
             # import the default NixOS modules from nix-bitcoin
             nix-bitcoin.nixosModules.default
             # Optional: Import the optional secure-node presets offered by nix-bitcoin
             (nix-bitcoin + "/modules/presets/secure-node.nix")
             #(nix-bitcoin + "/modules/presets/hardened.nix")
             {
               networking.hostName = "mybonk-jay2";
               services.clightning = {
                 extraConfig = ''
                   alias=MYBONK-SIGNET-2
                 '';
               };
             }
             ./hardware/mybonk_v3/hardware-configuration.nix
             ./configuration.nix
             ./housekeeping.nix
             ./health-check.nix
           ];
         };
      };
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = self.packages.${system}.install;

          install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = with pkgs; [ git ]; # deps
            text = ''
             ${./install.sh} "$@"
            ''; # the script
          };
        });

     apps = forAllSystems (system: {
       default = self.apps.${system}.install;

       install = {
         type = "app";
         program = "${self.packages.${system}.install}/bin/install";
       };
     });

 
    };
}

