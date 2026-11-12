function nixopt --description 'Optimise the Nix store'
    nix store optimise --verbose $argv
end
