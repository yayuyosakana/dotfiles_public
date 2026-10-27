# dotfiles_public の zsh 設定
# install.sh が ~/.config/dotfiles_public/init.zsh に置き、~/.zshrc から読み込む。
# 個別に止めたいときは、~/.zshrc の読み込みの行より前で次の変数を 1 にする。
#   DOTFILES_PUBLIC_NO_HERDR         Ghostty を開いたときに herdr を起動しない
#   DOTFILES_PUBLIC_NO_SUGGEST       打ちかけのコマンドに履歴の候補を出さない
#   DOTFILES_PUBLIC_NO_HIGHLIGHT     コマンドを色分けしない
#   DOTFILES_PUBLIC_NO_HISTORY_KEYS  ↑↓ キーで「打った文字から始まる履歴」を探さない
#   DOTFILES_PUBLIC_NO_ZOXIDE        z コマンド（行ったことのあるフォルダへ飛ぶ）を使わない

# brew の share フォルダ（Apple シリコンは /opt/homebrew、Intel は /usr/local）
_dfp_brew_share() {
  local p
  for p in ${HOMEBREW_PREFIX:-} /opt/homebrew /usr/local; do
    [[ -n $p && -f $p/share/$1 ]] && { print $p/share/$1; return }
  done
  return 1
}

# starship のプロンプト
# ~/.zshrc にもともと starship init がある場合、install.sh が
# DOTFILES_PUBLIC_SKIP_STARSHIP=1 を書くので、ここでは二重に読み込まない。
if [[ -z ${DOTFILES_PUBLIC_SKIP_STARSHIP:-} ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# 以下はキー入力に関わるので、対話シェルのときだけ読む
if [[ -o interactive ]]; then

  # zoxide：z <フォルダ名の一部> で、行ったことのあるフォルダへ飛ぶ（zi で一覧から選ぶ）
  # ~/.zshrc ですでに読み込んでいれば何もしない
  if [[ -z ${DOTFILES_PUBLIC_NO_ZOXIDE:-} ]] && (( $+commands[zoxide] )) \
    && ! (( $+functions[__zoxide_z] )); then
    eval "$(zoxide init zsh)"
  fi

  # 打ちかけのコマンドに、過去に打ったコマンドを薄い灰色で出す（→ キーで確定）
  if [[ -z ${DOTFILES_PUBLIC_NO_SUGGEST:-} ]] && ! (( $+functions[_zsh_autosuggest_start] )) \
    && _dfp_f=$(_dfp_brew_share zsh-autosuggestions/zsh-autosuggestions.zsh); then
    source $_dfp_f
  fi

  # ↑↓ キー：打った文字から始まる履歴だけをさかのぼる（何も打っていなければふつうの履歴）
  # ターミナルによって ↑ が ^[[A と ^[OA のどちらで届くかが違うので、両方に割り当てる
  if [[ -z ${DOTFILES_PUBLIC_NO_HISTORY_KEYS:-} ]]; then
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey '^[[A' up-line-or-beginning-search
    bindkey '^[OA' up-line-or-beginning-search
    bindkey '^[[B' down-line-or-beginning-search
    bindkey '^[OB' down-line-or-beginning-search
  fi

  # コマンドの色分け（あるコマンドは緑、打ち間違いは赤）
  # ほかの設定のあとに読む必要があるので、ここに置く
  if [[ -z ${DOTFILES_PUBLIC_NO_HIGHLIGHT:-} ]] && ! (( $+functions[_zsh_highlight] )) \
    && _dfp_f=$(_dfp_brew_share zsh-syntax-highlighting/zsh-syntax-highlighting.zsh); then
    source $_dfp_f
  fi
  unset _dfp_f
fi
unfunction _dfp_brew_share

# Ghostty を開いたら herdr を自動で起動する
# Ghostty の Cmd+T や Cmd+D は herdr への操作として設定してあるので、
# herdr の外で使うとキーが効かない。そのため Ghostty では最初から herdr に入る。
# - herdr の中のシェル（HERDR_ENV=1）では起動しない（入れ子にならないように）
# - herdr を抜ける（prefix+q）と、ふつうの zsh に戻る
# - 自動で起動したくないときは、~/.zshrc で DOTFILES_PUBLIC_NO_HERDR=1 を設定する
if [[ -o interactive ]] \
  && [[ ${TERM_PROGRAM:-} == ghostty ]] \
  && [[ -z ${HERDR_ENV:-} ]] \
  && [[ -z ${DOTFILES_PUBLIC_NO_HERDR:-} ]] \
  && (( $+commands[herdr] )); then
  herdr
fi
