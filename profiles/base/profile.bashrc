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

# Python lands in the base rootfs only as the interpreter for websockify
# (fydeos-vnc's noVNC WebSocket proxy) — nothing else in the image runs
# Python, and some boards' rootfs cannot afford a full runtime. Mask the
# parts websockify can never reach, at merge time so emerge-to-image
# peak usage shrinks too. Profile-wide (not per-package bashrc) because
# the payload spans several packages: dev-lang/python, dev-python/
# websockify, and the dev-python/ensurepip-* wheel bundles; the
# path-anchored globs cannot touch non-Python files.
#
#   * __pycache__ bytecode caches (~41 MiB): the rootfs is read-only,
#     so they could never be updated anyway; websockify just recompiles
#     its ~50 modules in memory once per daemon start.
#   * developer-workflow stdlib (~15 MiB): unittest, distutils,
#     lib2to3, pydoc_data, turtledemo, ensurepip (incl. bundled pip/
#     setuptools wheels), venv. websockify imports none of these
#     (verified against its import graph; its only lazy extras, numpy
#     and requests, degrade gracefully).
#
# Deliberately NOT PKG_INSTALL_MASK: binpkgs stay complete, so the
# dev/test-image Python under /usr/local keeps its full stdlib — hence
# the explicit /usr/local guard. INSTALL_MASK globs cross "/"
# (fnmatch), so python*/__pycache__ also catches nested caches like
# python3.11/email/mime/__pycache__.
if [[ $(cros_target) != "cros_host" && "${ROOT%/}" != */usr/local ]]; then
  openfyde_python_slim_mask="
    /usr/lib/python*/__pycache__
    /usr/lib/python*/unittest
    /usr/lib/python*/distutils
    /usr/lib/python*/lib2to3
    /usr/lib/python*/pydoc_data
    /usr/lib/python*/turtledemo
    /usr/lib/python*/ensurepip
    /usr/lib/python*/venv
  "
  INSTALL_MASK+=" ${openfyde_python_slim_mask}"
  unset openfyde_python_slim_mask
fi
