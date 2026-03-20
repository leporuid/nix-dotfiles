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
alias git = hub

source ($nu.default-config-dir | path join 'env.nu') 
mkdir ($nu.default-config-dir | path join 'vendor/autoload')
atuin init nu | save -f ($nu.default-config-dir | path join 'vendor/autoload/atuin.nu')
starship init nu | save -f ($nu.default-config-dir | path join 'vendor/autoload/starship.nu')
zoxide init nushell | save -f ($nu.default-config-dir | path join 'vendor/autoload/.zoxide.nu') 
