#!/bin/bash
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAGIC_ANCHOR="Setup by setup_osx.sh"
COMMON_DIR="$CONFIG_DIR/common"
COMMON_MODULES="$(ls $COMMON_DIR)"
LINK_FILE=""
install_base() {
    # sync all git submodule
    cd $CONFIG_DIR
    git submodule update --init --recursive
    for d in $COMMON_MODULES
    do
        $COMMON_DIR/$d/setup/setup.sh install
    done
}
install() {
    install_base
    # Installing packages
    cd $HOME
    #mkdir homebrew && curl -L https://github.com/Homebrew/homebrew/tarball/master | tar xz --strip 1 -C homebrew
    #$HOME/homebrew/bin/brew install zsh zsh-completions emacs

    # Setup bashrc and zshrc
    for f in "bashrc" "zshrc"
    do
        echo "Setting up $f"
        echo "# BEGIN: $MAGIC_ANCHOR" >> ~/.$f
        echo "export ZHANGYI_OSX_DIR=\"$CONFIG_DIR\"" >> ~/.$f
        if [ -f "$CONFIG_DIR/shell/$f" ]; then
            echo "Adding $f config"
            echo '. "$ZHANGYI_OSX_DIR/shell/'"$f"'"' >> ~/.$f
        fi
        echo "# END: $MAGIC_ANCHOR" >> ~/.$f
    done
    for f in $(echo $LINK_FILE)
    do
        if [ -f "$CONFIG_DIR/$f" ]; then
            echo "Setting up $f"
            ln -sf "$CONFIG_DIR/$f" ~/.$f
        fi
    done

    # Use zsh
    sudo dscl . -create $HOME UserShell $HOME/homebrew/bin/zsh
}
uninstall_base() {
    for d in $COMMON_MODULES
    do
        $COMMON_DIR/$d/setup/setup.sh uninstall
    done
}
uninstall() {
    uninstall_base
    TMP_FILE=$(mktemp)
    for f in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.emacs"
    do
        echo "Removing config from $f"
        sed "/$MAGIC_ANCHOR/,/$MAGIC_ANCHOR/d" $f > $TMP_FILE && mv $TMP_FILE $f
    done
    for f in $(echo $LINK_FILE)
    do
        if [ -f "$CONFIG_DIR/$f" ]; then
            echo "Removing file $f"
            find ~/.$f -type l -delete
        fi
    done
    sudo dscl . -create $HOME UserShell /bin/bash
}
case "$1" in
'install')
    install
    ;;
'uninstall')
    uninstall
    ;;
*)
    echo "Usage ${BASH_SOURCE[0]} install/uninstall"
    exit
    ;;
esac
