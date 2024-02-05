#!/usr/bin/env ruby
require 'faraday'
require 'json'
require 'time'
require 'date'
require '../../issue_auto_closer/config'
require '../../issue_auto_closer/github_api_client'
require '../../issue_auto_closer/slack_client'

config = IssueAutoCloser::Config.new
# config.validate_environment_variables!

client = IssueAutoCloser::GitHubApiClient.new(
  base_url: config.github_url,
  token: config.github_token,
  ignore_labels: config.ignore_labels
)
targets = client.fetch_old_branches(limit_date: config.limit_date, now: config.now)
# pp targets
