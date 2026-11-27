{
  flake.modules.nixos.audio =
    # PipeWire for ALSA and PulseAudio clients.
    {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      security.rtkit.enable = true;
    };
}
