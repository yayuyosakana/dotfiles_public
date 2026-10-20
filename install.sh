#!/bin/zsh
# dotfiles_public のセットアップ
#
#   ./install.sh               すべて入れる
#   ./install.sh --dry-run     何をするかだけ表示する（何も変えない）
#   ./install.sh --skip-brew   brew でのインストールを飛ばす（設定ファイルだけ置く）
#   ./install.sh --with-hunk   差分を見る道具 hunk（npm の hunkdiff）も入れる
#
# 何度実行しても同じ結果になる。置き換える前の設定は
# ~/.dotfiles_public_backup/<日時>/ に退避する。

emulate -L zsh
set -euo pipefail

REPO=${0:A:h}
DRY_RUN=0 SKIP_BREW=0 WITH_HUNK=0
for arg in "$@"; do
  case $arg in
    --dry-run)   DRY_RUN=1 ;;
    --skip-brew) SKIP_BREW=1 ;;
    --with-hunk) WITH_HUNK=1 ;;
    -h|--help)   sed -n '2,10p' $0 | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) print -u2 "不明なオプション: $arg"; exit 1 ;;
  esac
done

BACKUP=$HOME/.dotfiles_public_backup/$(date +%Y%m%d-%H%M%S)
STEP=0
step() { STEP=$((STEP + 1)); print "\n== $STEP. $1" }
info() { print "   $1" }
warn() { print "   [注意] $1" }
run()  { if (( DRY_RUN )); then print "   [dry-run] $*"; else "$@"; fi }

# 置き換える前のファイルを退避してからコピーする
place() {
  local src=$1 dest=$2
  if [[ -e $dest || -L $dest ]]; then
    if [[ ! -L $dest ]] && cmp -s $src $dest; then
      info "同じ内容なのでそのまま: ${dest/#$HOME/~}"
      return
    fi
    local saved=$BACKUP/${dest#$HOME/}
    run mkdir -p ${saved:h}
    run mv $dest $saved
    info "退避: ${dest/#$HOME/~} → ${saved/#$HOME/~}"
  fi
  run mkdir -p ${dest:h}
  run cp $src $dest
  info "配置: ${dest/#$HOME/~}"
}

if [[ $(uname) != Darwin ]]; then
  print -u2 "このセットアップは macOS 専用です。"
  exit 1
fi
(( DRY_RUN )) && print "dry-run です。何も変更しません。"

# ---------------------------------------------------------------
step "brew でアプリとフォントを入れる"
if (( SKIP_BREW )); then
  info "--skip-brew なので飛ばします"
elif ! command -v brew >/dev/null; then
  print -u2 "\nHomebrew が入っていません。"
  print -u2 "別のターミナルで https://brew.sh のコマンドを実行して入れてから、もう一度実行してください。"
  print -u2 "（途中で Mac のパスワードを聞かれるので、Claude Code の中からは入れられません）"
  exit 1
else
  run brew bundle --file=$REPO/Brewfile
fi

# ---------------------------------------------------------------
step "設定ファイルを置く"
place $REPO/config/ghostty/config     $HOME/.config/ghostty/config
place $REPO/config/herdr/config.toml  $HOME/.config/herdr/config.toml
place $REPO/config/starship.toml      $HOME/.config/starship.toml
place $REPO/zsh/init.zsh              $HOME/.config/dotfiles_public/init.zsh

# ---------------------------------------------------------------
step "~/.zshrc から読み込むようにする"
ZSHRC=$HOME/.zshrc
MARK_BEGIN='# >>> dotfiles_public >>>'
MARK_END='# <<< dotfiles_public <<<'
if [[ -f $ZSHRC ]] && grep -qF $MARK_BEGIN $ZSHRC; then
  info "すでに追加済み"
else
  skip_line=''
  if [[ -f $ZSHRC ]] && grep -q 'starship init' $ZSHRC; then
    skip_line=$'\nDOTFILES_PUBLIC_SKIP_STARSHIP=1  # ~/.zshrc にもともと starship init があるため'
    info "~/.zshrc にもともと starship init があるので、二重に読み込まないようにします"
  fi
  block="$MARK_BEGIN${skip_line}
[[ -f ~/.config/dotfiles_public/init.zsh ]] && source ~/.config/dotfiles_public/init.zsh
$MARK_END"
  if [[ -f $ZSHRC ]]; then
    run mkdir -p $BACKUP
    run cp $ZSHRC $BACKUP/.zshrc
    info "退避: ~/.zshrc → ${BACKUP/#$HOME/~}/.zshrc"
  fi
  if (( DRY_RUN )); then
    print "   [dry-run] ~/.zshrc の末尾に次を追加:"; print -- "$block" | sed 's/^/     /'
  else
    print -- "\n$block" >> $ZSHRC
    info "~/.zshrc の末尾に追加しました"
  fi
fi

# ---------------------------------------------------------------
step "herdr のプラグインを入れる"
if ! command -v herdr >/dev/null; then
  warn "herdr が見つからないので飛ばします（brew で入れたあと、もう一度実行してください）"
else
  installed=$(herdr plugin list 2>/dev/null || true)
  while read -r line; do
    [[ -z $line || $line == \#* ]] && continue
    repo=${line%@*} ref=${line#*@}
    if [[ $installed == *"github:$repo@"* ]]; then
      info "入っている: $repo"
      continue
    fi
    info "$repo (${ref[1,7]})"
    run herdr plugin install -y --ref $ref $repo || warn "$repo を入れられませんでした"
  done < $REPO/herdr-plugins.txt
fi

# ---------------------------------------------------------------
step "hunk（任意）"
if (( ! WITH_HUNK )); then
  info "入れません（入れるときは --with-hunk）"
elif ! command -v npm >/dev/null; then
  warn "npm がないので入れられません（brew install node のあとで npm install -g hunkdiff）"
else
  run npm install -g hunkdiff || warn "hunkdiff を入れられませんでした"
fi

# ---------------------------------------------------------------
step "確認"
GHOSTTY=/Applications/Ghostty.app/Contents/MacOS/ghostty
if (( DRY_RUN )); then
  info "dry-run なので確認は飛ばします"
else
  if [[ -x $GHOSTTY ]]; then
    if $GHOSTTY +validate-config >/dev/null 2>&1; then info "Ghostty の設定: OK"
    else warn "Ghostty の設定にエラーがあります: $GHOSTTY +validate-config で確認してください"; fi
  else
    warn "Ghostty.app が見つかりません"
  fi
  if command -v herdr >/dev/null; then
    herdr config check >/dev/null 2>&1 && info "herdr の設定: OK" || warn "herdr の設定にエラーがあります: herdr config check で確認してください"
  fi
  command -v starship >/dev/null && info "starship: $(starship --version | head -1)" || warn "starship が見つかりません"
  if ls ~/Library/Fonts /Library/Fonts 2>/dev/null | grep -qi 'UDEVGothic'; then
    info "フォント UDEV Gothic: OK"
  else
    warn "フォント UDEV Gothic が見つかりません（brew install --cask font-udev-gothic）"
  fi
fi

# ---------------------------------------------------------------
print "\n== 残りは手で行う作業です"
print "   1. GitHub にログインする（gh-pr プラグイン用）: 別のターミナルで  gh auth login"
print "   2. Claude Code と herdr の連携（任意）:  herdr integration install claude"
print "   3. Ghostty を一度終了して開き直す → herdr が自動で起動します"
print "   元に戻すときは README.md の「元に戻す」を見てください。"
