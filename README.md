# dotfiles_public

macOS 用の Ghostty（ターミナル）、herdr（AI エージェント向けの画面分割ツール）、starship（プロンプト）の設定一式です。

## 使い方

Claude Code を開いて、次のように頼むだけです。

```
https://github.com/yayuyosakana/dotfiles_public これでセットアップして
```

途中で Mac のパスワードや GitHub へのログインが必要になったときは、Claude が別のターミナルで実行するコマンドを教えてくれます。

> **Claude Code へ**：このリポジトリを `~/dotfiles_public` にクローンし、[CLAUDE.md](CLAUDE.md) の手順どおりに進めてください。設定ファイルは手で書き換えず、`install.sh` を使ってください。

自分で入れる場合は次のとおりです。

```
git clone https://github.com/yayuyosakana/dotfiles_public.git ~/dotfiles_public
cd ~/dotfiles_public
./install.sh --dry-run   # 何が変わるかを見る
./install.sh             # 入れる
```

## 入るもの

| もの | 内容 | 置き場所 |
|---|---|---|
| Ghostty | ターミナル。Cmd キーで herdr を操作できるようにしてある | `~/.config/ghostty/config` |
| herdr | 画面を分けて、複数の Claude Code を並べて動かす | `~/.config/herdr/config.toml` |
| herdr のプラグイン | gh-pr（PR の状態の表示）、tab-renamer、worktree-setup | `herdr-plugins.txt` の一覧 |
| starship | 入力行にフォルダや git のブランチを表示する | `~/.config/starship.toml` |
| UDEV Gothic | Ghostty で使うフォント | brew で入れる |
| gh | GitHub CLI。gh-pr プラグインが使う | brew で入れる |

`~/.zshrc` の末尾には、`~/.config/dotfiles_public/init.zsh` を読み込む3行が足されます。中身は starship の設定と、Ghostty を開いたときに herdr を自動で起動する設定です。

## キーの早見表

Ghostty の Cmd キーを、herdr の操作に割り当ててあります。herdr の中で使います。

| キー | 動き |
|---|---|
| Cmd+T | 新しいタブ |
| Cmd+D | 右に分割 |
| Cmd+Shift+D | 下に分割 |
| Cmd+W | ペインを閉じる |
| Cmd+Shift+W | タブを閉じる |
| Cmd+1〜9 | タブを切り替える |
| Cmd+Shift+[ と ] | 前と次のタブ |
| Cmd+Shift+N | 新しいワークスペース |
| Cmd+P | ワークスペースを選ぶ |
| Cmd+O | 呼んでいるエージェントへ移る |
| Cmd+Shift+Enter | ペインを最大化する、元に戻す |
| Cmd+B | サイドバーを開く、閉じる |
| Cmd+[ | コピーモード（スクロール、検索、コピー。q で抜ける） |
| Cmd+/ | herdr のキーの一覧を出す |
| Ctrl+Shift+H と L | 前と次のワークスペース |

Claude Code で便利なキーも足してあります。herdr の外でも使えます。

| キー | 動き |
|---|---|
| Ctrl+: | 「continue」と打って Enter を押す（止まった Claude に続けてもらう） |
| Ctrl+; | 「/exit」と打って Enter を押す（Claude Code を終了する） |
| Shift+Enter | 送信せずに改行する |

Ctrl+: は日本語配列（JIS）のキーボードで「:」のキーを押す前提です。英語配列では「'」のキーになります。

最初はマウスでも操作できます。クリックで選び、境目をドラッグして大きさを変え、右クリックでメニューが出ます。
herdr から抜けるときは Ghostty を Cmd+Q で終了します。中で動いているものは止まらず、次に開くとそのまま戻れます。すべて止めるときは `herdr server stop` を実行します。

## 好みに合わせて変える

- 文字の大きさ：`~/.config/ghostty/config` の `font-size = 19`
- 色：同じファイルの `theme = Adventure`。`ghostty +list-themes` で一覧が出ます
- herdr を自動で起動しない：`~/.zshrc` の読み込みの行より前に `DOTFILES_PUBLIC_NO_HERDR=1` を書く。このとき Cmd+T などは herdr の外では効かないので、`~/.config/ghostty/config` の「herdr へのキー転送」の部分も消してください
- 差分を見る道具 hunk（Cmd+Shift+U）：`./install.sh --with-hunk` で入ります（npm が必要）

Claude Code に「Ghostty の文字を小さくして」のように頼んでも変えられます。

## 元に戻す

1. `~/.zshrc` の `# >>> dotfiles_public >>>` から `# <<< dotfiles_public <<<` までを消す
2. `~/.dotfiles_public_backup/<日時>/` に退避した設定を元の場所に戻す
3. アプリも消すなら `brew uninstall --cask ghostty font-udev-gothic` と `brew uninstall herdr starship`
