# dotfiles_public の zsh 設定
# install.sh が ~/.config/dotfiles_public/init.zsh に置き、~/.zshrc から読み込む。

# starship のプロンプト
# ~/.zshrc にもともと starship init がある場合、install.sh が
# DOTFILES_PUBLIC_SKIP_STARSHIP=1 を書くので、ここでは二重に読み込まない。
if [[ -z ${DOTFILES_PUBLIC_SKIP_STARSHIP:-} ]] && (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

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
