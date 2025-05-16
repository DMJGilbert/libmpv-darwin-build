final: prev: {
  darwin = prev.darwin.overrideScope (
    final: prev: {
      xcode_16_3 = prev.xcode.overrideAttrs (prev: {
        outputHash = "sha256-YhYRcHnuZl4zdTQ1gnDJ0SilSPCVhoAbn1MCR5IY/C8=";
      });
      xcode = final.xcode_16_3;
    }
  );
}
