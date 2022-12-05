{

  description = "Utilities for packaging ASDF Common Lisp systems";

  #inputs.dev.url = "github:uthar/dev";
  inputs.nixpkgs.url = "github:lukego/nixpkgs/shaderc-2022.4";

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      #devpkgs = nixpkgs.outputs.packages.${system};
      callWithLisps = x: pkgs.callPackage x { inherit (nixpkgs) abcl clasp sbcl; };
      lisps = callWithLisps ./.;
    in
    {
      packages = { inherit (lisps) abcl ccl clasp clisp ecl sbcl; };
      devShells.default = callWithLisps ./shell.nix;
      pkgs = pkgs;
    });

}
