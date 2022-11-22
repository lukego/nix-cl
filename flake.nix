{

  description = "Utilities for packaging ASDF Common Lisp systems";

  inputs.dev.url = "github:uthar/dev";

  outputs = { self, dev, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      nixpkgs = dev.inputs.nixpkgs;
      pkgs = nixpkgs.legacyPackages.${system};
      devpkgs = dev.outputs.packages.${system};
      callWithLisps = x: pkgs.callPackage x { inherit (devpkgs) abcl clasp sbcl; };
      lisps = callWithLisps ./.;
      buildLogOf = pkgs.callPackage ./buildLogOf.nix pkgs;
    in
    rec {
      packages = { inherit (lisps) abcl ccl clasp clisp ecl sbcl; };
      #devShells.default = callWithLisps ./nix.shell;
      hydraJobs =
        let
          inherit (builtins) isAttrs hasAttr;
          inherit (pkgs.lib) filterAttrs mapAttrs;
        in
          mapAttrs (n: d: buildLogOf d)
            (filterAttrs (n: d: (isAttrs d) && (hasAttr "systems" d))
              lisps.sbcl.pkgs);
    });

}
