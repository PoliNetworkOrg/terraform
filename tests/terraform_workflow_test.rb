#!/usr/bin/env ruby

require "yaml"

workflow_path = File.expand_path("../.github/workflows/terraform-environments.yml", __dir__)
raw = File.read(workflow_path)
workflow = YAML.safe_load(raw, aliases: true)
jobs = workflow.fetch("jobs")
errors = []

permissions = workflow.fetch("permissions", {})
errors << "the workflow must be allowed to comment on pull requests" unless permissions["pull-requests"] == "write"

plan = jobs.fetch("plan", {})
environments = plan.dig("strategy", "matrix", "environment")
errors << "plan must run once for legacy and once for k3s" unless environments == %w[legacy k3s]

plan_steps = plan.fetch("steps", [])
plan_commands = plan_steps.map { |step| step["run"] }.compact.join("\n")
errors << "plan must use detailed exit codes" unless plan_commands.include?("-detailed-exitcode")
errors << "plan must save its exit code for downstream jobs" unless plan_commands.include?("exitcode.txt")
errors << "plan must render the saved plan without command output" unless plan_commands.include?("terraform show -no-color tfplan > plan.diff")

artifact_step = plan_steps.find { |step| step["uses"]&.start_with?("actions/upload-artifact@") }
artifact_name = artifact_step&.dig("with", "name")
errors << "each environment must publish a distinct saved-plan artifact" unless artifact_name&.include?("matrix.environment")

comment = jobs.fetch("comment", {})
errors << "the PR comment job must only run for pull requests" unless comment.fetch("if", "").include?("pull_request")
comment_source = comment.fetch("steps", []).map { |step| [step["run"], step.dig("with", "script")].compact.join("\n") }.join("\n")
errors << "the PR comment must include the legacy plan" unless comment_source.include?("legacy")
errors << "the PR comment must include the k3s plan" unless comment_source.include?("k3s")
errors << "the PR comment must be updated instead of duplicated" unless comment_source.include?("updateComment")
errors << "the PR comment must read only the rendered plan diff" unless comment_source.include?("plan.diff") && !comment_source.include?("plan.txt")

changes = jobs.fetch("changes", {})
errors << "a push job must detect whether either plan contains changes" unless changes.fetch("if", "").include?("push")

apply = jobs.fetch("apply", {})
apply_condition = apply.fetch("if", "")
errors << "apply must run only on a stable push with pending changes" unless apply_condition.include?("push") && apply_condition.include?("has_changes")
errors << "apply must require production approval" unless apply["environment"] == "production"

apply_source = apply.fetch("steps", []).map { |step| step["run"] }.compact.join("\n")
k3s_apply = apply_source.index("environments/k3s")
legacy_apply = apply_source.index("environments/legacy")
errors << "apply must consume both saved plans, in k3s then legacy order" unless k3s_apply && legacy_apply && k3s_apply < legacy_apply
saved_plan_applies = apply_source.scan(/terraform(?:\s+-chdir=\S+)?\s+apply[^\n]*tfplan/)
errors << "apply must use the saved plan files" unless saved_plan_applies.length == 2
errors << "apply must not create a fresh plan" if apply_source.include?("terraform plan")

if errors.empty?
  puts "terraform workflow regression test: PASS"
  exit 0
end

warn "terraform workflow regression test: FAIL"
errors.each { |error| warn "- #{error}" }
exit 1
