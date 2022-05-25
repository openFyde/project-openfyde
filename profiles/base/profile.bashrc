openfyde_stack_bashrc() {
        local cfg cfgd

        # New location.
        cfgd="/mnt/host/source/src/overlays/project-openfyde/${CATEGORY}/${PN}"
        export BASHRC_FILESDIR="${cfgd}/files"
        for cfg in ${PN} ${P} ${PF} ; do
                cfg="${cfgd}/${cfg}.bashrc"
                [[ -f ${cfg} ]] && . "${cfg}"
        done
}
openfyde_stack_bashrc
