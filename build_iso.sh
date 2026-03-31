  # nixos-rebuild build-image --image-variant iso-installer -I nixos-config="./iso.nix"
# nixos-rebuild build-image --image-variant iso-installer 
nixos-rebuild build-image --flake .#installer --image-variant iso-installer
