#!/usr/bin/env bash
opensuse*|suse)
log "Using openSUSE/SUSE installation path"
zypper refresh
zypper install -y docker || { err "zypper failed"; exit 1; }
;;
fedora|centos|rhel|rocky|almalinux)
err "This installer is intended for non-RedHat-family distros. For RedHat-based systems, please use the official Docker docs for your distribution."
exit 2
;;
*)
err "Unsupported or unknown distribution: $OS"
exit 3
;;
esac


# Place any downloaded packages into PKG_DIR for safekeeping
# (for repo-based installs there may be no direct packages to move,
# but ensure the directory exists and is writable for root only)
log "Packages/artefak akan disimpan di: $PKG_DIR"


# Enable and start service if systemd present (or openrc for Alpine)
if command -v systemctl >/dev/null 2>&1; then
log "Enabling and starting docker via systemd"
systemctl enable docker --now || { err "Failed to enable/start docker service"; exit 4; }
else
# try openrc
if command -v rc-update >/dev/null 2>&1; then
log "Enabling and starting docker via OpenRC"
rc-update add docker default || true
service docker start || true
fi
fi


# Validate installation
if command -v docker >/dev/null 2>&1; then
docker --version >/tmp/docker_version.txt 2>&1 || true
DOCKER_VER=$(cat /tmp/docker_version.txt || echo "(unknown)")
log "Docker installed: $DOCKER_VER"
else
err "Docker binary not found after installation"
exit 5
fi


# Final success box in green
echo -e "${GREEN}+------------------------------------------+${NC}"
echo -e "${GREEN}| INSTALLATION SUCCESSFULLY YEAYYY |${NC}"
echo -e "${GREEN}+------------------------------------------+${NC}"


success "Installation complete. Run 'docker run hello-world' to test."
}


# Run main with error handling
if [[ $(id -u) -ne 0 ]]; then
err "This script must be run as root. Please use sudo.";
exit 10
fi


main "$@"
