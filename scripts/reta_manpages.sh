#!/usr/bin/env sh
# Central manual-page manifest for shell, Pixi and CMake install/check entrypoints.
# Standard installation exposes only public user commands.

reta_public_manpages() {
    cat <<'MANPAGES'
generate_html.1
grundStrukHtml.1
reta.1
rp.1
rpb.1
rpe.1
rpl.1
MANPAGES
}
