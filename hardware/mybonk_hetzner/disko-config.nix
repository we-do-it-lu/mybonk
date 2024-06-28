# Example to create a bios compatible gpt partition
{lib, ...}: {
  disko.devices = {
    disk.vda = {
      device = lib.mkDefault "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "2G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
          #root = {
          #  name = "root";
          #  size = "10G";
          #  content = {
          #    type = "lvm_pv";
          #    vg = "pool";
          #  };
          #};
          swap = {
            name = "swap";
            size = "8000M";
            content = {
              type = "swap";
             # discardPolicy = "both";
              #resumeDevice = true; # resume from hiberation from this device
            };
          };
        };
      };
    };
    #lvm_vg = {
    #  pool = {
    #    type = "lvm_vg";
    #    lvs = {
    #      root = {
    #        size = "100%FREE";
    #        content = {
    #          type = "filesystem";
    #          format = "ext4";
    #          mountpoint = "/";
    #          mountOptions = [
    #            "defaults"
    #          ];
    #        };
    #      };
    #    };
    #  };
    #};

    



    disk.disk2 = {
      device = lib.mkDefault "/dev/sdb";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "data";
            };
          };
        };
      };
    };
    lvm_vg = {
      data = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/data";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    }; 


  };
}


