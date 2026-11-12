# Shared Hjem wiring across Darwin and NixOS (moni-dz style)
{
  inputs,
  ...
}:
{
  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
      inputs.hjem-impure.hjemModules.default
      ../hjem
    ];
  };
}
