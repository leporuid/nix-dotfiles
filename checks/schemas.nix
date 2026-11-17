# Pure-Nix schema evaluation check across flake outputs (Nix_Schemas-Evaluator pattern).
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (inputs) self;
  # Exclude `checks` itself to avoid infinite recursion when evaluating inside `checks`.
  outputKeys = builtins.filter (k: self ? ${k}) [
    "darwinConfigurations"
    "darwinModules"
    "devShells"
    "formatter"
    "hjemConfigurations"
    "hjemModules"
    "nixosConfigurations"
    "nixosModules"
    "overlays"
    "packages"
    "rumModules"
    "schemas"
  ];

  collectChecks =
    path: inv:
    (lib.mapAttrsToList (name: ok: {
      path = "${path}.${name}";
      inherit ok;
    }) (inv.evalChecks or { }))
    ++ lib.concatLists (
      lib.mapAttrsToList (
        childName: childInv:
        collectChecks (if path == "" then childName else "${path}.${childName}") childInv
      ) (inv.children or { })
    );

  failures = lib.concatLists (
    map (
      key:
      let
        schema = self.schemas.${key};
        results = collectChecks key (schema.inventory self.${key});
      in
      assert schema.version == 1;
      builtins.filter (entry: !entry.ok) results
    ) outputKeys
  );
in
assert lib.assertMsg (failures == [ ]) (
  "Schema evaluation failed for: " + lib.concatMapStringsSep ", " (f: f.path) failures
);
pkgs.runCommand "schemas-check" { } ''
  touch "$out"
''
