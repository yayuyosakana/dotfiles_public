# dotfiles_public

macOS 用の Ghostty（ターミナル）、herdr（AI エージェント向けの画面分割ツール）、starship（プロンプト）の設定と、zsh の入力を少し楽にする設定の一式です。

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

## Ghostty と herdr を使う理由

- **Ghostty**：macOS で軽く動くターミナルです。画面の描画に Mac の GPU（Metal）を使い、見た目や操作は Mac のふつうのアプリと同じです。Zig という言語で書かれています。設定は1つのテキストファイルにまとまっていて、キーも自由に割り当てられます。
- **herdr**：Rust で書かれた、ターミナルの中で動く道具です。1つの画面を分けて、複数の Claude Code を並べて動かせます。どの Claude が作業中か、入力を待っているか、終わったかがタブやワークスペースの一覧に出ます。呼んでいる Claude には Cmd+O で移れるので、画面を順に見て回らなくて済みます。Ghostty を閉じても中の作業は止まらず、開き直すとそのまま戻れます。

**組み合わせると何がいいか**：仕事を分けています。Ghostty は文字の描画とフォント、Mac のキー操作を受け持ち、herdr は画面の分割と、作業を残しておくことと、Claude の状態の表示を受け持ちます。

- Ghostty だけでも画面は分けられます。ただ、どの Claude が待っているかは分からず、Ghostty を閉じると中の作業も止まります。
- herdr はどのターミナルの中でも動きます。ただ、ターミナルの中の道具には Cmd キーが届かないので、操作は Ctrl+B から始まるキーになります。
- Ghostty の設定で Cmd キーを herdr のキーに置き換えているので、Cmd+T や Cmd+D といった Mac でおなじみのキーで herdr を操作できます。

## 入るもの

| もの | 内容 | 置き場所 |
|---|---|---|
| Ghostty | ターミナル。Cmd キーで herdr を操作できるようにしてある | `~/.config/ghostty/config` |
| herdr | 画面を分けて、複数の Claude Code を並べて動かす | `~/.config/herdr/config.toml` |
| herdr のプラグイン | gh-pr（PR の状態の表示）、tab-renamer、worktree-setup | `herdr-plugins.txt` の一覧 |
| starship | 入力行にフォルダや git のブランチを表示する | `~/.config/starship.toml` |
| UDEV Gothic | Ghostty で使うフォント | brew で入れる |
| gh | GitHub CLI。gh-pr プラグインが使う | brew で入れる |
| zsh-autosuggestions | 打ちかけると、過去に打ったコマンドが薄い灰色で出る。→ キーで確定 | brew で入れる |
| zsh-syntax-highlighting | 打ったコマンドを色分けする。あるコマンドは緑、打ち間違いは赤 | brew で入れる |
| zoxide | `z フォルダ名の一部` で、行ったことのあるフォルダへ飛ぶ | brew で入れる |

`~/.zshrc` の末尾には、`~/.config/dotfiles_public/init.zsh` を読み込む3行が足されます。中身は starship の設定、上の 3 つの zsh の道具の読み込み、↑↓ キーの設定、Ghostty を開いたときに herdr を自動で起動する設定です。

## 最初にやってみる

1. Ghostty を開くと herdr が立ち上がります。
2. `cd` で作業するフォルダに移り、`claude` で Claude Code を起動します。
3. Cmd+D で画面を右に分け、そちらでも `claude` を起動します。
4. 両方に別々の作業を頼みます。片方が入力を待ったり終わったりしたら、Cmd+O でそちらに移ります。
5. キーを忘れたら Cmd+/ で一覧を出します。Cmd+Q で Ghostty を閉じても作業は続き、開き直すと元の画面に戻ります。

ターミナルでの入力も少し楽になっています。

- 打ちかけると、前に打ったコマンドが薄い灰色で出ます。→ キーで確定します。
- `git` などと打ってから ↑ を押すと、その文字で始まる履歴だけをさかのぼれます。
- 打ったコマンドが赤くなったら、打ち間違いか、まだ入っていないコマンドです。
- 一度 `cd` したフォルダには、名前の一部だけで飛べます（例：`~/projects/report` なら `z rep`）。`zi` で一覧から選べます。

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
- zsh の道具を一部止める：`~/.zshrc` の読み込みの行より前に、`DOTFILES_PUBLIC_NO_SUGGEST=1`（候補の表示）、`DOTFILES_PUBLIC_NO_HIGHLIGHT=1`（色分け）、`DOTFILES_PUBLIC_NO_HISTORY_KEYS=1`（↑↓ キー）、`DOTFILES_PUBLIC_NO_ZOXIDE=1`（`z`）のうち止めたいものを書く。`~/.zshrc` ですでに読み込んでいるものは、二重には読み込みません
- 差分を見る道具 hunk（Cmd+Shift+U）：`./install.sh --with-hunk` で入ります（npm が必要）

Claude Code に「Ghostty の文字を小さくして」のように頼んでも変えられます。

## 元に戻す

1. `~/.zshrc` の `# >>> dotfiles_public >>>` から `# <<< dotfiles_public <<<` までを消す
2. `~/.dotfiles_public_backup/<日時>/` に退避した設定を元の場所に戻す
3. アプリも消すなら `brew uninstall --cask ghostty font-udev-gothic` と `brew uninstall herdr starship zsh-autosuggestions zsh-syntax-highlighting zoxide`
