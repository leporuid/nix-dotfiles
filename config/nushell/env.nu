$env.__NIX_DARWIN_SET_ENVIRONMENT_DONE = 1 

# Set theme for bat
$env.BAT_THEME = "Catppuccin Macchiato"

$env.config.show_banner = false



$env.config = {
  hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      direnv export json | from json | default {} | load-env
      if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
        $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
      }
    }]
  }
}

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}


def --env cx [arg] {
    cd $arg
    ls -l
}


# To load from a custom file you can use:
 source ($nu.default-config-dir | path join 'vendor/autoload/atuin.nu')



