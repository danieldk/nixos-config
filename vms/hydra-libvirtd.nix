{
  hydra = {
    deployment.targetEnv = "libvirtd";
    deployment.libvirtd = {
      baseImageSize = 40;
      memorySize = 4096;
      extraDomainXML = ''
        <cpu mode='custom' match='exact' check='partial'>
          <model fallback='allow'>Haswell</model>
          <feature policy='disable' name='rtm'/>
          <feature policy='disable' name='hle'/>
        </cpu>
      '';
    };
  };
}

