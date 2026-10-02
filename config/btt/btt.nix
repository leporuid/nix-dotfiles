{ user, ... }:

{
  targets.darwin.defaults."com.hegenberg.BetterTouchTool" = {
    PrefsCustomFolder = "${flake}/config/btt";
    BTTAutoLoadPath = "${flake}/config/btt/btt.bttpreset";
    LoadPrefsFromCustomFolder = true;
  };
}
