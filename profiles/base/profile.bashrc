openfyde_stack_bashrc() {
  local cfg cfgd

  cfgd="/mnt/host/source/src/overlays/project-openfyde/${CATEGORY}/${PN}"
  for cfg in ${PN} ${P} ${PF} ; do
    cfg="${cfgd}/${cfg}.bashrc"
    [[ -f ${cfg} ]] && . "${cfg}"
  done

  export OPENFYDE_BASHRC_FILESDIR="${cfgd}/files"

  cfgd_patches="/mnt/host/source/src/overlays/project-openfyde-patches/${CATEGORY}/${PN}"
  for cfg in ${PN} ${P} ${PF} ; do
    cfg="${cfgd_patches}/${cfg}.bashrc"
    [[ -f ${cfg} ]] && . "${cfg}"
  done

  export OPENFYDE_PATCHES_BASHRC_FILESDIR="${cfgd_patches}/files"
}

openfyde_stack_bashrc
