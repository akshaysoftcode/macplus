# Infra — Terraform

## Important: I couldn't run `terraform validate`/`plan` myself

This code was written in a sandbox with no network access and no Terraform
binary, so it's been checked for obvious structural issues (brace
balance, variable references matching between modules) but **not**
actually validated against the AWS provider. Run these on your machine
before trusting it further — do this before anything else:

```bash
cd infra/bootstrap && terraform init && terraform validate
cd ../environments/stage && terraform init -backend=false && terraform validate
```

`-backend=false` lets validate run without a real backend configured yet.
Report back anything that fails and I'll fix it directly.

## Run order

### 1. Bootstrap (once, by hand, local state)

```bash
cd infra/bootstrap
terraform init
terraform apply -var="state_bucket_name=<yourname>-devsecops-tfstate"
```

Copy the three outputs it prints (`state_bucket`, `lock_table`,
`github_oidc_provider_arn`) — you need all three next.

### 2. Wire up the stage backend

Edit `infra/environments/stage/backend.tf`, replace
`REPLACE-WITH-YOUR-STATE-BUCKET-NAME` with the `state_bucket` output.

### 3. Fill in stage variables

```bash
cd infra/environments/stage
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`: paste in `github_oidc_provider_arn` from step 1,
and set `github_org`/`github_repo` to match where you push this repo.

### 4. Apply

```bash
terraform init
terraform plan    # read this before apply — confirm ~15-20 resources, no surprises
terraform apply
```

This creates: VPC (2 AZ, public+private subnets, 1 NAT gateway), KMS key,
IAM roles (GitHub Actions deploy role, EKS cluster/node roles, ALB
controller IRSA role — unattached until Chapter 7), EKS cluster + managed
node group, 2 ECR repos.

**Expect this apply to take 12-18 minutes** — the EKS control plane is the
long pole. Start it first if you're doing other setup in parallel.

## Cost control — read before you leave this running overnight

Billable the moment `apply` finishes, whether or not you're using it:
- EKS control plane (~$0.10/hr)
- NAT gateway (~$0.045/hr + data processing)
- 2x t3.medium nodes (~$0.0836/hr combined, varies by region)
- EBS volumes attached to nodes

None of this is "pay per request" — it bills by the hour regardless of
use. When you're done for the day:

```bash
cd infra/environments/stage
terraform destroy
```

Keep the bootstrap resources (S3 state bucket, DynamoDB table, OIDC
provider) — those cost effectively nothing idle and you'll re-apply stage
against them next session. Only destroy bootstrap if you're stopping the
whole project.

## What's intentionally deferred

- **ALB controller IAM policy attachment** — the IRSA role exists but has
  no policy attached yet (`alb_controller_policy_arn` defaults to `""`).
  Attached in Chapter 7 when the controller is actually deployed via Helm.
- **`terraform.tfstate` for bootstrap** — stays local, per-machine, never
  committed. If you rebuild your machine, you'd need to `terraform import`
  the bootstrap resources or accept losing that state (the resources
  themselves aren't destroyed, just untracked — recoverable either way).
