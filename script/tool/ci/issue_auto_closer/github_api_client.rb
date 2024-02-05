module IssueAutoCloser
  class GitHubApiClient
    @base_url = ''
    @ignore_labels = []
    @headers = {}

    def initialize(base_url:, token:, ignore_labels:)
      @base_url = base_url
      @token = token
      @ignore_labels = ignore_labels
      @headers = {
        'Authorization' => "Bearer #{token}",
        'Accept' => 'application/vnd.github.v3+json'
      }
    end

    def conn
      @conn ||= Faraday.new(url: @base_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def fetch_old_issues_and_pulls(limit_date:, now:)
      page = 1
      targets = []
      puts "REQUEST URL: #{@base_url}/issues"
      loop do
        response = conn.get('issues', { state: 'open', per_page: 100, page: page }, @headers)
        rows = JSON.parse(response.body)
        break if response.status != 200 || rows.empty?

        targets << filter_rows(limit_date.iso8601, rows)
        page += 1
      end
      compressed_response(targets.flatten, now)
    end

    def close(row)
      uri = row[:is_pr] ? "pulls/#{row[:number]}" : "issues/#{row[:number]}"
      puts "REQUEST URL: #{@base_url}/#{uri}"
      res = conn.patch(uri, { state: 'closed' }.to_json, @headers)
      res.status
    end

    private

    def compressed_response(hash, now)
      hash.map do |item|
        {
          url: item['html_url'],
          number: item['number'],
          title: item['title'],
          create_user: item['user']['login'],
          is_pr: item.key?('pull_request'),
          labels: item['labels'].map { |l| l['name'] },
          dates_not_updated: (now.to_date - Date.parse(item['updated_at'])).to_i
        }
      end
    end

    def filter_rows(limit, rows)
      rows.select do |row|
        puts "---- #{row['title']} / #{row['html_url']} ----"
        puts "  term: #{row['updated_at']} < #{limit}"
        puts "  labels: #{row['labels'].map { _1['name'] }.join(', ')}"
        within_term = limit < row['updated_at']
        has_exclusion_label = has_exclusion_labels?(row['labels'])
        is_target = !within_term && !has_exclusion_label
        puts "  #{is_target ? 'Target' : 'Skip  '}(within_term: #{within_term}, has_exclusion_label: #{has_exclusion_label})"
        is_target
      end
    end

    def has_exclusion_labels?(labels)
      labels.any? { |label| @ignore_labels.include?(label['name']) }
    end
  end
end
