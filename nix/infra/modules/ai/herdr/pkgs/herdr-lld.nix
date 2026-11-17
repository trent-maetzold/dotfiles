# herdr linked with lld; ld.bfd fails with ".eh_frame_hdr refers to overlapping FDEs".
{
  flake.overlays.herdr-lld = final: _: {
    herdr-lld = final.llm-agents.herdr.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.llvmPackages.lld];
      env = (old.env or {}) // {RUSTFLAGS = "${old.env.RUSTFLAGS or ""} -C link-arg=-fuse-ld=lld";};
    });
  };
}
