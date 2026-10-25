# Declarative fish plugin and optional manpage completion installation.
{ ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.fish;
  enableGeneratedCompletions = cfg.generateManCompletions || (cfg.completionPackages != [ ]);

  fishIndent =
    name: text:
    pkgs.runCommand name {
      nativeBuildInputs = [ pkgs.fish ];
      inherit text;
      passAsFile = [ "text" ];
    } "env HOME=$(mktemp -d) fish_indent < $textPath > $out";

  # Paths later in the list will overwrite those already linked.
  destructiveSymlinkJoin =
    args_@{
      name,
      paths,
      preferLocalBuild ? true,
      allowSubstitutes ? false,
      postBuild ? "",
      ...
    }:
    let
      args =
        removeAttrs args_ [
          "name"
          "postBuild"
        ]
        // {
          inherit preferLocalBuild allowSubstitutes;
        };
    in
    pkgs.runCommand name args ''
      mkdir -p $out
      for i in $paths; do
        if [ -z "$(find $i -prune -empty)" ]; then
          cp -srf $i/* $out
        fi
      done
      ${postBuild}
    '';

  generateCompletions =
    let
      getName =
        attrs: attrs.name or "${attrs.pname or "pname-missing"}-${attrs.version or "version-missing"}";
    in
    package:
    pkgs.runCommand "${getName package}-fish-completions"
      {
        srcs = [
          package
        ]
        ++ lib.filter (p: p != null) (
          builtins.map (outName: package.${outName} or null) config.home.extraOutputsToInstall
        );
        nativeBuildInputs = [
          pkgs.python3
          pkgs.fish
        ];
        preferLocalBuild = true;
      }
      ''
        # The generator script is embedded in the fish binary (fish 4.x no
        # longer ships it at share/fish/tools/), so extract it first.
        generator=$PWD/create_manpage_completions.py
        fish --no-config -c 'status get-file tools/create_manpage_completions.py' > "$generator"

        mkdir -p $out
        for src in $srcs; do
          if [ -d $src/share/man ]; then
            find -L $src/share/man -type f -exec python "$generator" --directory $out {} + > /dev/null
          fi
        done
      '';
in
{
  options.my.programs.fish = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Plugins that will be installed and activated.
      '';
    };

    generateManCompletions = lib.mkEnableOption "generating Fish completions from all home.packages manpages";

    completionPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Specific packages from which to generate Fish manpage completions.
      '';
    };
  };

  config = {
    xdg.dataFile."fish/vendor_conf.d/00_source_plugins.fish" = lib.mkIf (cfg.plugins != [ ]) {
      source = fishIndent "source_plugins.fish" ''
        for plugin in ${lib.concatStringsSep " " cfg.plugins}
          if test -d $plugin/functions
            set fish_function_path $fish_function_path[1] $plugin/functions $fish_function_path[2..]
          end

          if test -d $plugin/completions
            set fish_complete_path $fish_complete_path[1] $plugin/completions $fish_complete_path[2..]
          end

          # Sourcing files in both places allows supporting OMF plugins too.
          for file in $plugin/conf.d/*.fish $plugin/*.fish
            test -f $file -a -r $file
            and source $file
          end
        end
      '';
    };

    programs.man.generateCaches = lib.mkIf (enableGeneratedCompletions && config.programs.man.package != null) (
      lib.mkDefault true
    );

    xdg.dataFile."fish/generated_completions" = lib.mkIf enableGeneratedCompletions {
      source =
        let
          cmp = a: b: (a.meta.priority or 0) > (b.meta.priority or 0);
          targetPackages =
            if cfg.completionPackages != [ ] then cfg.completionPackages else config.home.packages;
        in
        destructiveSymlinkJoin {
          name = "${config.home.username}-fish-completions";
          paths = map generateCompletions (lib.sort cmp targetPackages);
        };
    };

    manual.manpages.enable = false;

    xdg.dataFile."fish/vendor_conf.d/99_generated_completions.fish" = lib.mkIf enableGeneratedCompletions {
      source = fishIndent "99_generated_completions.fish" ''
        set -l genpath ${config.xdg.dataHome}/fish/generated_completions

        if test -d $genpath; and not contains -- $genpath $fish_complete_path
          set --append fish_complete_path $genpath
        end
      '';
    };
  };
}
