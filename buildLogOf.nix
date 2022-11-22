{ pkgs, writeScript, stdenv, coreutils, ... }:

let
  # Custom builder for mkDerivation to produce build logs instead of normal output.
  #
  # Output will be a text file containing the output on stdout/stderr during build.
  # One-liner header and trailer metadata is also included.
  #
  # Usage: mkDerivation { ... } // { builder = <logging-builder>; }
  logging-builder = writeScript "logging-builder.sh"
    ''
      #!${stdenv.shell}
      # Run the real builder as mkDerivation normally would
      echo "START: building $out" | ${coreutils}/bin/tee .logging-builder.log

      set +e
      set -o pipefail
      ${stdenv.shell} -c 'set -e; source $stdenv/setup; genericBuild' 2>&1 \
        | ${coreutils}/bin/tee -a .logging-builder.log
      status=$?

      echo "FINISH: exit status $status for $out" >> .logging-builder.log
      [ -e "$out" ] && ${coreutils}/bin/rm -rf $out
      ${coreutils}/bin/cp .logging-builder.log $out
    '';
  # buildLogOf :: derivation -> derivation
  #
  # Update a derivation to produce the logs from the build process instead of
  # its normal output.
  buildLogOf = derivation:
    derivation.overrideAttrs (o: { builder = logging-builder; });
in buildLogOf
