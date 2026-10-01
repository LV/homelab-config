DIR := $(shell pwd)

.PHONY: all
all: switch

.PHONY: switch
switch:
	nixos-rebuild switch --flake $(DIR)/#homelab --sudo --show-trace

.PHONY: lint
lint:
	nix flake check
	nix develop -c statix check .
	nix develop -c deadnix --fail .

.PHONY: fmt
fmt:
	nix fmt

.PHONY: update
update:
	nix flake update
