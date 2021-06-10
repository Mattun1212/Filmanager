require 'net/http'

# コマンドライン引数を取得
src_url = 'https://www.unitedcinemas.jp/tsukuba/film.php?film=12875'

# リダイレクト先URLを取得
redirect_url = Net::HTTP.get_response(URI.parse(src_url))['location']

# リダイレクト先URLを出力
puts redirect_url