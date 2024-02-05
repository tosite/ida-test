module IssueAutoCloser
  class Config
    GITHUB_BASE_URL = 'https://api.github.com/repos/tosite/nicocale.php'
    REQUIRED_KEYS = %w(GITHUB_TOKEN SLACK_WEBHOOK)
    OPTIONAL_KEYS = %w(NOTIFY_TEMPLATE CLOSED_TEMPLATE IGNORE_LABELS LIMIT_DAYS)

    def validate_environment_variables!
      REQUIRED_KEYS.each do |key|
        if ENV[key].empty?
          raise "key: #{key} is not specified.abort."
        end
      end
    end

    def github_url
      GITHUB_BASE_URL
    end

    def slack_webhook_url
      ENV.fetch('SLACK_WEBHOOK', nil)
    end

    def ignore_labels
      ENV.fetch('SLACK_WEBHOOK', '').split(',')
    end

    def github_token
      ENV.fetch('GITHUB_TOKEN', '')
    end

    def notify_template
      ENV.fetch('NOTIFY_TEMPLATE', nil)
    end

    def closed_template
      ENV.fetch('CLOSED_TEMPLATE', nil)
    end

    def now
      Time.now.utc
    end

    def limit_date
      now - (ENV['LIMIT_DAYS'].to_i * 24 * 60 * 60)
    end

    def limit_days
      ENV['LIMIT_DAYS']
    end
  end
end
