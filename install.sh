#!/run/current-system/sw/bin/bash
#
doas nixos-rebuild build --target-host mybonk-jay --build-host mybonk-jay --flake ".#mybonk-jay"

