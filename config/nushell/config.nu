# Nushell Config File
# Yu-Min Peng's workstation shell configuration

alias m-open = ^open
alias lg = lazygit
alias reload = exec nu
alias ks = ktoolbox sync_creator
alias cat = bat
alias find = fd

def _linux-distribution [] {
    if $nu.os-info.name != 'Linux' {
        return 'Not available on macOS'
    }

    if not ('/etc/os-release' | path exists) {
        return 'Unknown (missing /etc/os-release)'
    }

    let values = open --raw /etc/os-release
        | lines
        | where {|line| $line =~ '^[A-Za-z_][A-Za-z0-9_]*='}
        | each {|line|
            let parts = $line | split column '=' 2
            {
                key: $parts.column1
                value: ($parts.column2 | str trim -c '"')
            }
        }
        | reduce -f {} {|item, acc| $acc | upsert $item.key $item.value }

    $values.PRETTY_NAME? | default ($values.NAME? | default 'Unknown Linux distribution')
}

def os-info [] {
    let host = sys host
    let shell_path = $nu | get -o shell-path | default $nu.current-exe

    {
        shell: ($shell_path | path basename)
        shell_path: $shell_path
        login_shell: ($nu | get -o loginshell-path | default 'Unknown')
        os: $host.name
        kernel: $host.kernel_version
        hostname: $host.hostname
        distribution: (_linux-distribution)
    }
}

let autoload_dir = $nu.data-dir | path join 'vendor/autoload'
mkdir $autoload_dir

let atuin_autoload = $autoload_dir | path join 'atuin.nu'
if not ($atuin_autoload | path exists) {
    if not (which atuin | is-empty) {
        atuin init nu | save -f $atuin_autoload
    }
}

let starship_autoload = $autoload_dir | path join 'starship.nu'
if not ($starship_autoload | path exists) {
    if not (which starship | is-empty) {
        starship init nu | save -f $starship_autoload
    }
}

let zoxide_autoload = $autoload_dir | path join '.zoxide.nu'
if not ($zoxide_autoload | path exists) {
    if not (which zoxide | is-empty) {
        zoxide init nushell | save -f $zoxide_autoload
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
