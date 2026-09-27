.PHONY: all switch

DIR := $(shell pwd)

all: switch

switch:
	sudo -E nixos-rebuild switch --flake $(DIR)/#homelab --show-trace

lint:
	nix flake check
	nix develop -c statix check .
	nix develop -c deadnix --fail .

fmt:
	nix fmt
