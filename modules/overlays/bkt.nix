{inputs, ...}: {perSystem = {system, ...}: {overlayAttrs.bkt = inputs.bkt.packages.${system}.bkt;};}
