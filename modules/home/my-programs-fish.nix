{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.fish;

  fishIndent =
    name: text:
    pkgs.runCommand name {
      nativeBuildInputs = [ pkgs.fish ];
      inherit text;
      passAsFile = [ "text" ];
    } "env HOME=$(mktemp -d) fish_indent < $textPath > $out";
in
{
  options.my.programs.fish = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Plugins that will be installed and activated.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.plugins != [ ]) {
      xdg.dataFile."fish/vendor_conf.d/00_source_plugins.fish" = {
        source = fishIndent "source_plugins.fish" ''
          for plugin in ${lib.concatStringsSep " " cfg.plugins}
            if test -d $plugin/functions
              set fish_function_path $fish_function_path[1] $plugin/functions $fish_function_path[2..]
            end

            if test -d $plugin/completions
              set fish_complete_path $fish_complete_path[1] $plugin/completions $fish_complete_path[2..]
            end

            for file in $plugin/conf.d/*.fish $plugin/*.fish
              test -f $file -a -r $file
              and source $file
            end
          end
        '';
      };
    })

    {
      manual.manpages.enable = false;

      xdg.dataFile."fish/vendor_conf.d/99_generated_completions.fish".source =
        fishIndent "99_generated_completions.fish" ''
          set -l genpath ${config.xdg.dataHome}/fish/generated_completions

          if test -d $genpath; and not contains -- $genpath $fish_complete_path
            set --append fish_complete_path $genpath
          end
        '';
    }
  ];
}