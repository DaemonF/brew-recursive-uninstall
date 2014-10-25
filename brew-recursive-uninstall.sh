BREW_BIN=$(which brew)
SAVE_FILE="$HOME/.config/brewAutoRemove"

if [ ! -f "$SAVE_FILE" ]; then
  $BREW_BIN leaves > "$SAVE_FILE"
fi

_remove_from_file() {
  TEMP=$(grep -v "^$1\$" "$SAVE_FILE")
  echo "$TEMP" > "$SAVE_FILE"
}

_files_to_remove() {
  KEEP=$(basename "$(tr '\n' '|' < "$SAVE_FILE")" \|)
  REMOVE=$($BREW_BIN leaves | egrep -v "$KEEP")
  basename $(tr '\n' ' ' <<< "$REMOVE") " "
}

brew() {
  case "$1" in
  "install")
    # TODO Support calls to install with more than one package name.
    $BREW_BIN $@ && _remove_from_file "$2" && echo "$2" >> "$SAVE_FILE"
    ;;
  "uninstall"|"remove")
    echo "exec: $BREW_BIN $@"
    $BREW_BIN $@ && _remove_from_file "$2"

    REMOVE="$(_files_to_remove)"
    while [ "$REMOVE" != " " ]; do
      $BREW_BIN uninstall $REMOVE
      REMOVE=$(_files_to_remove)
    done
    ;;
  *)
    $BREW_BIN $@
    ;;
  esac
}
