# セットアップの手順（Claude Code 向け）

このリポジトリは、macOS に Ghostty（ターミナル）、herdr（AI エージェント向けの画面分割ツール）、starship（プロンプト）を入れて、作者と同じ設定にするためのものです。
利用者から「これでセットアップして」と頼まれたら、次の順に進めてください。

## 1. 始める前に

- macOS であることを確かめます（`uname` が `Darwin`）。ほかの OS なら、対応していないことを伝えて止めます。
- リポジトリがまだ手元になければ、`~/dotfiles_public` にクローンします。
  ```
  git clone https://github.com/yayuyosakana/dotfiles_public.git ~/dotfiles_public
  ```
- 利用者に、何をするかを短く伝えて了承をもらいます。
  - brew で ghostty、font-udev-gothic、herdr、starship、gh を入れる
  - `~/.config` の ghostty、herdr、starship の設定を置き換える（今の設定は `~/.dotfiles_public_backup/<日時>/` に退避する）
  - `~/.zshrc` の末尾に読み込み用の3行を足す
  - Ghostty を開くと herdr が自動で起動するようになる

## 2. 何が変わるかを見せる

```
cd ~/dotfiles_public && ./install.sh --dry-run
```

出力を見て、置き換わる設定ファイルがあれば利用者に伝えます。

## 3. インストール

```
cd ~/dotfiles_public && ./install.sh
```

- Homebrew が入っていないと止まります。Homebrew は途中で Mac のパスワードを聞かれるため、Claude Code の中からは入れられません。利用者に、別のターミナル（macOS の「ターミナル」アプリで構いません）で https://brew.sh のコマンドを実行してもらい、終わったらもう一度 `./install.sh` を実行します。
- brew が途中でパスワードを聞いてきて止まった場合も同じです。利用者に、別のターミナルで `cd ~/dotfiles_public && ./install.sh` を実行してもらいます。
- `sudo` は自分で実行しないでください。
- 会社の管理で brew やアプリのインストールが禁止されている場合は、無理に回避せず、利用者にそう伝えて止めます。

## 4. 仕上げ（利用者に確認してから）

`install.sh` の最後に出る「残りは手で行う作業」を、次のとおり進めます。

1. **GitHub へのログイン**：`gh auth status` でログイン済みか確かめます。まだなら、`gh auth login` は対話式なので、利用者に別のターミナルで実行してもらいます。herdr の gh-pr プラグイン（PR の状態の表示）に使います。
2. **Claude Code と herdr の連携**：`herdr integration install claude` は `~/.claude` にフックを書き込むので、実行してよいか利用者に聞いてから実行します。
3. **Ghostty の開き直し**：利用者に、Ghostty を Cmd+Q で一度終了して開き直してもらいます。開くと herdr が自動で起動します。Claude Code が今動いているターミナルは、Claude からは再起動できません。

## 5. 終わったら利用者に伝えること

- 最初はマウスで操作できます。ペインやタブをクリックして選び、境目をドラッグして大きさを変え、右クリックでメニューが出ます。
- よく使うキーは README.md の「キーの早見表」にあります。とくに Cmd+T（新しいタブ）、Cmd+D（右に分割）、Ctrl+Shift+H と L（前と次のワークスペース）、Ctrl+:（Claude に continue を送る）、Ctrl+;（Claude Code を終了する）は最初に伝えてください。herdr の中で Cmd+/ を押すと、キーの一覧が出ます。
- herdr の中で `claude` と打てば Claude Code が起動します。
- 元に戻す方法は README.md の「元に戻す」にあります。

## してはいけないこと

- herdr のペインの中（環境変数 `HERDR_ENV=1` がある所）で `herdr` を起動しないでください。入れ子になるため、herdr が止めます。
- herdr のキー、設定項目、コマンドのオプションを推測で作らないでください。分からないときは `herdr --help`、`herdr --default-config`、https://herdr.dev/llms.txt を見ます。herdr は tmux とは別のものなので、tmux の知識を当てはめないでください。
- このリポジトリが扱う3つ以外の設定（`~/.gitconfig`、Claude Code の設定など）は、頼まれない限り変えないでください。
- 設定ファイルを手で上書きしないでください。置き換えは `install.sh` に任せます（退避してから置き換えます）。
