"""Register the vendor USB and Zoom virtual channels in Citrix module.ini."""
import configparser
import sys
from pathlib import Path


def configure(path):
    config = configparser.ConfigParser(interpolation=None, strict=False)
    config.optionxform = lambda optionstr: optionstr
    config.read(path)
    ica = config["ICA 3.0"]
    drivers = [name.strip() for name in ica["VirtualDriver"].split(",")]
    for name, library in [("GenericUSB", "VDGUSB.DLL"), ("ZoomMedia", "ZoomMedia.so")]:
        if name not in drivers:
            drivers.append(name)
        ica[name] = "On"
        if not config.has_section(name):
            config.add_section(name)
        config[name]["DriverName"] = library
    ica["VirtualDriver"] = ", ".join(drivers)
    with Path(path).open("w") as output:
        config.write(output)


if __name__ == "__main__":
    configure(sys.argv[1])
