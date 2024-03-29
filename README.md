# Filmanager

Filmanagerは、見たい映画の上映終了を逃さないようにするためのLINE Botです。忙しくて映画を見に行く予定を立てるのが難しい人向けに、見たい映画の終了日が近づいたらLINEでリマインドする機能を提供します。

## デプロイURL

[https://filmanager.herokuapp.com/](https://filmanager.herokuapp.com/)

## 主な機能

1. **気になる映画をチェック**:
   - 自分が訪れる映画館で上映されている気になる映画を登録できます。

2. **終了情報の自動通知**:
   - 登録した映画の上映終了情報が、毎朝自動で通知されます。

3. **リッチメニューでの映画確認**:
   - LINEトーク画面から、登録した映画やもうすぐ終了する映画を簡単に確認できます。

4. **LINEからの映画削除**:
   - 見終わった映画や興味を失った映画を、トーク画面から簡単に削除できます。

5. **LINEアカウントでのログイン**:
   - アカウント作成不要。LINEでのログインが可能で、すぐに利用開始できます。

## 技術スタック

- **フレームワーク**: Ruby (Sinatra)
- **データベース**: PostgreSQL
- **定期実行**: Heroku Scheduler
- **スクレイピング**: Nokogiri
