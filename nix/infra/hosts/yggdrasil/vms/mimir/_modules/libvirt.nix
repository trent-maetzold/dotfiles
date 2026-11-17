{NixVirt, ...}: {
  imports = [NixVirt.nixosModules.default];

  disko = {
    zfs.settings.ignoredDatasets = ["tank/unraid-cache"];

    devices.zpool.tank.datasets.unraid-cache = {
      type = "zfs_volume";
      size = "7T";

      options = {
        volblocksize = "64K";
        compression = "zstd";
      };
    };
  };

  boot = {
    kernelParams = [
      "intel_iommu=on"
      "vfio-pci.ids=1000:0097"
    ];

    extraModprobeConfig = ''
      options vfio-pci ids=1000:0097
    '';

    blacklistedKernelModules = ["mpt3sas"];
    initrd.kernelModules = ["vfio_pci" "vfio" "vfio_iommu_type1"];
  };

  virtualisation = {
    libvirtd = {
      allowedBridges = ["br0"];
      # VFIO passthrough cannot be suspended.
      onShutdown = "shutdown";

      qemu.verbatimConfig = ''
        user = "root"
        group = "root"
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero", "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/kqemu", "/dev/rtc", "/dev/hpet", "/dev/sev",
          "/dev/vfio/vfio", "/dev/vfio/17",
          "/dev/bus/usb", "/dev/bus/usb/004/002"
        ]
      '';
    };

    libvirt = {
      enable = true;

      connections."qemu:///system".domains = [
        {
          active = true;

          definition = NixVirt.lib.domain.writeXML {
            type = "kvm";
            name = "unraid";
            uuid = "43f9066d-7ce2-4c38-9b9b-3021b4b38ab5";

            memory = {
              count = 64;
              unit = "GiB";
            };

            vcpu = {count = 16;};

            os = {
              type = "hvm";
              arch = "x86_64";
              machine = "q35";
              boot = [{dev = "hd";}];
              bootmenu = {enable = true;};
            };

            cpu = {mode = "host-passthrough";};

            features = {
              acpi = {};
              apic = {};
            };

            clock = {
              offset = "utc";

              timer = [
                {
                  name = "rtc";
                  tickpolicy = "catchup";
                }
                {
                  name = "pit";
                  tickpolicy = "delay";
                }
                {
                  name = "hpet";
                  present = false;
                }
              ];
            };

            on_poweroff = "destroy";
            on_reboot = "restart";
            on_crash = "restart";

            devices = {
              emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

              controller = [
                {
                  type = "usb";
                  model = "qemu-xhci";
                  ports = 8;
                }
                {
                  type = "scsi";
                  model = "virtio-scsi";
                  index = 0;
                }
              ];

              disk = [
                {
                  type = "block";
                  device = "disk";

                  driver = {
                    name = "qemu";
                    type = "raw";
                    cache = "none";
                    io = "native";
                  };

                  source = {dev = "/dev/zvol/tank/unraid-cache";};

                  target = {
                    dev = "sda";
                    bus = "scsi";
                  };

                  serial = "unraid-cache";
                }
              ];

              interface = {
                type = "bridge";
                source = {bridge = "br0";};
                model = {type = "virtio";};
              };

              graphics = {
                type = "vnc";
                autoport = true;

                listen = {
                  type = "address";
                  address = "127.0.0.1";
                };
              };

              video = {
                model = {
                  type = "qxl";
                  ram = 65536;
                  vram = 65536;
                };
              };

              serial = {type = "pty";};
              console = {type = "pty";};

              input = [
                {
                  type = "tablet";
                  bus = "usb";
                }
              ];
            };

            qemu-commandline = {
              arg = [
                {value = "-device";}
                {value = "qemu-xhci,id=usb2,bus=pcie.0,addr=0x3";}
                {value = "-device";}
                {value = "usb-host,hostbus=4,hostport=6,id=usb-unraid,bus=usb2.0,bootindex=0";}
                {value = "-device";}
                {value = "vfio-pci,host=0000:82:00.0,id=hba,bus=pcie.0,addr=0x4,rombar=0";}
              ];
            };
          };
        }
      ];
    };
  };
}
