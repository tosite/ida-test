require 'date'
require 'fileutils'

# 今日の日付を取得
today = Date.today

# 変更があったかどうかを示すフラグ
changes = false

# entry 配下の *.md ファイルを取得
Dir.glob('entry/**/*.md').each do |file|
  content = File.read(file)

  # draft: true を含むファイルを抽出
  if content.include?('draft: true')
    # date: 2024-01-04T01:00:00.000Z の日付部分を抽出
    if content =~ /date: (\d{4}-\d{2}-\d{2})T/
      date = Date.parse($1)

      # 日付が今日のものを抽出
      if date == today
        # draft: true を draft: false に書き換え
        new_content = content.gsub('draft: true', 'draft: false')
        File.write(file, new_content)
        changes = true
      end
    end
  end
end

# 変更があったかどうかを出力
puts "changes=#{changes}"
puts "branch_name=#{today.strftime('%Y%m%d')}-publish"
