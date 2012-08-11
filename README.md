post-gcalendar
==============

##概要
　Google Calendar に予定を送信する。

　cronなどで定期的な実行内容などをpostします。
例えばバックアップ作業の結果などを。

　当然文面も定型文となるので、事前に作成しておいたテンプレートから送信する事が出来ます。
　毎回 google Calendar に同じ文面を書き込むといった作業をしなくなるのでハッピー。

##使い方

　初回は引数なしで起動してください。

　そうするとアカウントとパスワードを尋いてきますので入力します。
　パスワードなどは保存されますので、次回以降は不用です。

　次に定型文ファイルを作成します。ファイルは YAML 形式で記述します。

###例

    Calendar : Backup
    Title : /home Backup完了
    Contents : /home のフルバックアップが完了しました。

　**Calendar** は Google Calendar の名前を指定します。  
　**Title** はカレンダーの見出しです。  
　**Contents** は詳細な説明文を記入します。

　適当な名前を付けて保存しましたら、_--config_ オプションで定型文ファイルを指定して実行します。

###例

`~$ post-gcalendar.pl --config ~/backuo.yml`


　定型作業などに組合せてお使いください。



###必要なモジュール

　ubuntu だと *Net::Google::Calendar* だけ CPAN から取得してこないとダメかも。
(先にapt-getしてからcpanした方がいいかも)  
　他はリポジトリにありますので、

    ~$ sudo apt-get install libcrypt-simple-perl libyaml-perl libpath-class-perl libfile-homedir-perl libterm-readkey-perl 

でいけます。




ライセンスはGPLv3とします。