{
  castle = {
    deployment.targetEnv = "none";
    deployment.targetHost = "95.179.147.165";

    fileSystems."/" =
    { device = "/dev/disk/by-uuid/333a5573-81ff-4c8b-b40c-0edf5e5a3b41";
      fsType = "ext4";
    };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/45612f70-4b3b-4b4c-bdb7-c6ac962ed6b0"; }
    ];
  };
}
