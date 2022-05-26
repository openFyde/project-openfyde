openfyde_stack_bashrc() {
        local cfg cfgd

        # New location.
        cfgd="/mnt/host/source/src/overlays/project-openfyde/${CATEGORY}/${PN}"
        for cfg in ${PN} ${P} ${PF} ; do
                cfg="${cfgd}/${cfg}.bashrc"
                [[ -f ${cfg} ]] && . "${cfg}" && export FYDERC_FILESDIR="${cfgd}/files"
        done
}
openfyde_stack_bashrc
