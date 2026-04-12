#!/bin/sh
# Bootstrap script for leporuid/nix-dotfiles.
# Enters the dev shell and runs the initial configuration switch.
set -e

nix develop --command run switch-host
