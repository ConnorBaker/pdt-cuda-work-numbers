{
  perSystem = {
    lib,
    taPkgs,
    ...
  }: {
    packages = lib.trivial.pipe taPkgs [
      (lib.attrsets.mapAttrsToList (name: value: [
        (lib.attrsets.nameValuePair "magma-${name}" value.magma)
        (lib.attrsets.nameValuePair "torch-${name}" value.python3Packages.torch)
        (lib.attrsets.nameValuePair "cudnn-${name}" value.cudaPackages.cudnn)
      ]))
      builtins.concatLists
      builtins.listToAttrs
    ];
  };
}
