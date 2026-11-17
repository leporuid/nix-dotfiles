$env.config = {
  show_banner: false
  hooks: {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      let direnv_raw = (direnv export json | str trim)
      if ($direnv_raw | is-not-empty) {
        $direnv_raw | from json | default {} | load-env
      }
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
