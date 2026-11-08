# Nushell Config File
#
# version = "0.95.0"

# For more information on defining custom themes, see
# https://www.nushell.sh/book/coloring_and_theming.html
# And here is the theme collection
# https://github.com/nushell/nu_scripts/tree/main/themes


# Hide welcome message


alias m-open = ^open
alias lg = lazygit
alias reload = exec nu
alias ks = ktoolbox sync_creator
alias cat = bat
alias find = fd

source ($nu.default-config-dir | path join 'env.nu') 
mkdir ($nu.default-config-dir | path join 'vendor/autoload')

if not ($nu.default-config-dir | path join 'vendor/autoload/atuin.nu' | path exists) {
    atuin init nu | save -f ($nu.default-config-dir | path join 'vendor/autoload/atuin.nu')
}

if not ($nu.default-config-dir | path join 'vendor/autoload/starship.nu' | path exists) {
    starship init nu | save -f ($nu.default-config-dir | path join 'vendor/autoload/starship.nu')
}

if not ($nu.default-config-dir | path join 'vendor/autoload/.zoxide.nu' | path exists) {
    zoxide init nushell | save -f ($nu.default-config-dir | path join 'vendor/autoload/.zoxide.nu')
} 
