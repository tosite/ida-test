module IssueAutoCloser
  class SlackClient
    @webhook_url = ''

    def initialize(webhook_url:)
      @webhook_url = webhook_url
    end

    def build_message(template, issues, pulls, limit_days, ignore_labels)
      puts '---- issues --------------------'
      issue_link = issues.empty? ? 'Noting' : issues.join("\n")
      pp issue_link
      puts '---- pulls ---------------------'
      pull_link = pulls.empty? ? 'Noting' : pulls.join("\n")
      pp pull_link
      puts '--------------------------------'
      template.gsub("%ISSUES%", issue_link)
              .gsub("%PULLS%", pull_link)
              .gsub("%LIMIT%", limit_days)
              .gsub("%IGNORE_LABELS%", ignore_labels.join(', '))
    end

    def send_slack_message(template:, issues:, pulls:, limit_days: nil, ignore_labels: nil)
      payload = {
        attachments: [
          {
            mrkdwn_in: ["text"],
            color: "warning",
            text: build_message(template, issues, pulls, limit_days, ignore_labels),
            parse: 'none',
            as_user: true,
            footer: "https://github.com/tosite/idle-destroyer-actions"
          }
        ]
      }

      conn = Faraday.new(url: @webhook_url)
      response = conn.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = payload.to_json
      end

      if response.success?
        puts 'Slack message sent successfully!'
      else
        raise "Failed to send Slack message.(#{response.body})"
      end
    end
  end
end
