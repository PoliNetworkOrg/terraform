#!/usr/bin/env ruby

require "yaml"

workflow_path = File.expand_path("../.github/workflows/terraform-environments.yml", __dir__)
raw = File.read(workflow_path)
workflow = YAML.safe_load(raw, aliases: true)
jobs = workflow.fetch("jobs")
errors = []

permissions = workflow.fetch("permissions", {})
errors << "the workflow must be allowed to comment on pull requests" unless permissions["pull-requests"] == "write"

terraform = jobs.fetch("terraform", {})
environments = terraform.dig("strategy", "matrix", "environment")
errors << "Terraform checks must run for legacy and k3s" unless environments == %w[legacy k3s]

terraform_steps = terraform.fetch("steps", [])
terraform_commands = terraform_steps.map { |step| step["run"] }.compact.join("\n")
errors << "each environment must run terraform fmt" unless terraform_commands.include?("terraform fmt -check")
errors << "each environment must run terraform init" unless terraform_commands.include?("terraform init")
errors << "each environment must run terraform validate" unless terraform_commands.include?("terraform validate -no-color")
errors << "each environment must run terraform plan" unless terraform_commands.include?("terraform plan -no-color")
errors << "pull-request jobs must never apply Terraform" if terraform_commands.include?("terraform apply")

comment = terraform_steps.find { |step| step["uses"]&.start_with?("actions/github-script@") }
errors << "each environment must publish its PR plan" unless comment&.fetch("if", "")&.include?("pull_request")
comment_source = comment&.dig("with", "script").to_s
errors << "PR comments must be updated instead of duplicated" unless comment_source.include?("updateComment")
errors << "PR comments must be distinct for each environment" unless comment_source.include?("terraform-plan:${environment}")

plan_status = terraform_steps.find { |step| step["name"] == "Terraform Plan Status" }
errors << "a failed plan must fail its environment job" unless plan_status&.fetch("if", "")&.include?("steps.plan.outcome == 'failure'")

apply = jobs.fetch("apply", {})
apply_condition = apply.fetch("if", "")
errors << "apply must run only for pushes to stable" unless apply_condition.include?("push") && apply_condition.include?("refs/heads/stable")
errors << "apply must wait for the Terraform jobs" unless Array(apply["needs"]).include?("terraform")
errors << "apply must require production approval" unless apply["environment"] == "production"

apply_steps = apply.fetch("steps", [])
apply_commands = apply_steps.map { |step| step["run"] }.compact.join("\n")
k3s_apply = apply_steps.index { |step| step["name"] == "Terraform Apply (k3s)" }
legacy_apply = apply_steps.index { |step| step["name"] == "Terraform Apply (legacy)" }
errors << "stable must apply k3s then legacy" unless k3s_apply && legacy_apply && k3s_apply < legacy_apply
errors << "both environments must use the original apply command" unless apply_commands.scan("terraform apply -auto-approve -input=false").length == 2

errors << "the workflow must not manage the K3s SSH key" if raw.match?(/K3S_ADMIN_SSH_PUBLIC_KEY|compose-vm-ssh-public-key|terraform-plan-only/)

if errors.empty?
  puts "terraform workflow regression test: PASS"
  exit 0
end

warn "terraform workflow regression test: FAIL"
errors.each { |error| warn "- #{error}" }
exit 1
