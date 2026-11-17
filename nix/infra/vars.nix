# Shared by every host and user: the values features take as module args,
# merged into the flake's inputs.
{
  domain = "trkm.io";
  acmeEmail = "tkm89@proton.me";
  timeZone = "America/Chicago";
  flakePath = "/home/tm/code/asgard";
  bitwardenEmail = "trent@maetzold.co";

  tailnet = {
    loginServer = "https://hs.trkm.io";
    domain = "ts.trkm.io";
    subnet = "100.64.0.0/10";
  };
}
