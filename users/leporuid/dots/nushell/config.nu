# Nushell Config File
# Yu-Min Peng's workstation shell configuration

alias m-open = ^open
alias lg = lazygit
alias reload = exec nu
alias ks = ktoolbox sync_creator
alias cat = bat
alias find = fd

source ($nu.default-config-dir | path join 'env.nu')
mkdir ($nu.default-config-dir | path join 'vendor/autoload')

if not ($nu.default-config-dir | path join 'vendor/autoload/atuin.nu' | path exists) {
    if not (which atuin | is-empty) {
        atuin init nu | save -f ($nu.default-config-dir | path join 'vendor/autoload/atuin.nu')
    }
}

if not ($nu.default-config-dir | path join 'vendor/autoload/starship.nu' | path exists) {
    if not (which starship | is-empty) {
        starship init nu | save -f ($nu.default-config-dir | path join 'vendor/autoload/starship.nu')
    }
}

if not ($nu.default-config-dir | path join 'vendor/autoload/.zoxide.nu' | path exists) {
    if not (which zoxide | is-empty) {
        zoxide init nushell | save -f ($nu.default-config-dir | path join 'vendor/autoload/.zoxide.nu')
    }
}

# Carapace multi-shell completer integration
let carapace_completer = {|spans|
    if (which carapace | is-empty) {
        return null
    }

    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^.*ERR$' | is-empty) { $in } else { null }
}

$env.config = ($env.config? | default {})
$env.config = ($env.config | upsert completions {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
        enable: true
        max_results: 100
        completer: $carapace_completer
    }
})
