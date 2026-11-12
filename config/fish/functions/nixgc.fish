function nixgc --description 'Collect unused Nix store paths'
    nix store gc --verbose $argv
end
