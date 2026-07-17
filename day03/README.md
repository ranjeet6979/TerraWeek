# ☁️ TerraWeek Day 3 — Providers, Resources & Your First Cloud Infra

**Date:** Tuesday, 14th July 2026

Time to touch **real cloud infrastructure**! Today you'll configure a **provider**, use **data sources** and **meta-arguments** (`for_each`, `count`, `depends_on`, `lifecycle`), and provision a small network + compute stack on the cloud of your choice. 🏗️

---

## 🎯 Learning Goals

- Configure a **provider** properly with **version pinning** and **region**.
- Understand **resources** vs **data sources**.
- Use meta-arguments: **`count`**, **`for_each`**, **`depends_on`**, **`lifecycle`**.
- Provision, update, and destroy real cloud resources safely.

---

## ⚙️ Setup: Authenticate Your Cloud

Pick **one** provider and configure its CLI (never hard-code credentials in `.tf` files!):

- **AWS** → `aws configure` (uses `~/.aws/credentials`) — provider `hashicorp/aws ~> 6.0`
- **Azure** → `az login` — provider `hashicorp/azurerm ~> 4.0`
- **GCP** → `gcloud auth application-default login` — provider `hashicorp/google ~> 6.0`
- **Utho** → API token env var — provider `uthoplatforms/utho`

---

## 🗺️ 60-Second Networking Primer (read this first!)

Today jumps from a single container to a real cloud network. Don't panic — here are the **6 building blocks** you'll create, in plain English:

| Block | What it is | Real-world analogy |
|-------|------------|--------------------|
| **VPC** | Your own private, isolated network in the cloud (a range of IPs like `10.0.0.0/16`) | Your own gated neighborhood |
| **Subnet** | A slice of the VPC's IPs (`10.0.1.0/24`), lives in one Availability Zone | A street in that neighborhood |
| **Internet Gateway (IGW)** | The door between your VPC and the public internet | The neighborhood's main gate |
| **Route Table** | Rules that say "traffic for the internet → go via the IGW" | Road signs / GPS routes |
| **Security Group (SG)** | A stateful virtual firewall on the instance (which ports are open) | A bouncer checking who gets in |
| **EC2 Instance** | The actual virtual machine running your app | A house on the street |

**How they connect:** an **EC2 instance** lives in a **subnet**, inside a **VPC**. To reach the internet, the subnet's **route table** sends traffic through the **IGW**, and the **security group** decides which ports (e.g. 80/HTTP) are allowed in.

```
Internet ──▶ [IGW] ──▶ [Route Table] ──▶ [ Public Subnet ] ──▶ [SG] ──▶ [EC2]
                                          (inside the VPC)
```

> 💡 You'll build exactly this stack in Task 3. Re-read this table if a resource name ever feels confusing.

---

## 📝 Tasks

### Task 1: Providers & Version Pinning
- Add a `terraform` block with `required_version` and `required_providers` (pin with `~>`).
<br>![Terraform Block](example/terraform_block.png)

- Explain **why version pinning matters** and what the `~>` (pessimistic) operator does.
<br>Version pinning locks your software to specific dependency versions.
<br>It Locks software to specific dependency versions. It ensures build stability, repeatability, and security across different environments (local development vs. production) by preventing unexpected upstream updates.
<br>~> operator locks upto specific minor releases without upgrading to version higher than that. 
<br>1. Three-Digit Specification (Patch Lock)
* **Format:** `~> X.Y.Z` (e.g., `~> 2.1.0`)
* **Behavior:** Locks the major and minor versions. Only the patch version varies.
* **Range:** `>= 2.1.0` and `< 2.2.0`
* **Examples:** Installs `2.1.1` or `2.1.9`, but blocks `2.2.0`.
<br>Two-Digit Specification (Minor Lock)
* **Format:** `~> X.Y` (e.g., `~> 2.1`)
* **Behavior:** Locks the major version. The minor and patch versions vary.
* **Range:** `>= 2.1` and `< 3.0`
* **Examples:** Installs `2.2.0` or `2.5.1`, but blocks `3.0.0`.

- **Bonus:** configure a second provider **alias** (e.g. a second AWS region) and explain when you'd use it.
<br>![Second Provider](example/TerraformProvider2.png)

### Task 2: Resources vs Data Sources
- Create at least one **resource** (something new).
- Use at least one **`data`** source to *read* existing info (e.g. `aws_ami`, `aws_availability_zones`, or your default VPC).
- Explain the difference: **resources create/manage**, **data sources only read**.

<br>Terraform: Resources vs. Data Sources

1. Resources (`resource`)
* **Purpose**: **Write & Manage**. Used to create, update, and delete infrastructure.
* **State**: Tracked in `terraform.tfstate`. Terraform controls its entire lifecycle.
* **Example**: Creating a brand new AWS S3 bucket or EC2 instance.

2. Data Sources (`data`)
* **Purpose**: **Read-Only**. Used to fetch information from existing infrastructure outside the current configuration.
* **State**: Not managed by Terraform. Safe to run as it makes zero infrastructure changes.
* **Example**: Querying AWS to get the latest Ubuntu AMI ID or looking up an existing VPC ID.

Code Syntax Example

```hcl
# READ: Fetches existing VPC information by its tag
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["production-vpc"]
  }
}

# WRITE: Creates a new subnet inside that existing VPC
resource "aws_subnet" "new_subnet" {
  vpc_id     = data.aws_vpc.existing_vpc.id # Reference data source output
  cidr_block = "10.0.1.0/24"
}
```

### Task 3: Provision a Cloud Stack
Use the **AWS starter code in [`./example`](./example)** (or adapt to Azure/GCP). It builds a minimal, free-tier-friendly stack:
- a **VPC** + **public subnet** + **internet gateway** + **route table**
- a **security group**
- an **EC2 instance** using a **data source** to find the latest Amazon Linux 2023 AMI


cd example
terraform init
```text
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.0"...
- Installing hashicorp/aws v6.55.0...
- Installed hashicorp/aws v6.55.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
terraform validate
```text
Success! The configuration is valid.
```
terraform plan
```text
data.aws_ami.al2023: Reading...
data.aws_availability_zones.available: Reading...
aws_vpc.main: Refreshing state... [id=vpc-0c80ece1b08345982]
data.aws_availability_zones.available: Read complete after 1s [id=us-east-1]
data.aws_ami.al2023: Read complete after 2s [id=ami-0fd6240f599091088]
aws_internet_gateway.igw: Refreshing state... [id=igw-02f71846055c2bf30]
aws_subnet.public: Refreshing state... [id=subnet-03d46d50fcbf3a512]
aws_security_group.web: Refreshing state... [id=sg-07bd746ffcc9a7a4c]
aws_route_table.public: Refreshing state... [id=rtb-034fff886fa0f35db]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-0f262d2ca18bfaede]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-0fd6240f599091088"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "us-east-1"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = "subnet-03d46d50fcbf3a512"
      + tags                                 = {
          + "Name" = "terraweek-web"
        }
      + tags_all                             = {
          + "Day"       = "03"
          + "ManagedBy" = "terraform"
          + "Name"      = "terraweek-web"
          + "Project"   = "terraweek-2026"
        }
      + tenancy                              = (known after apply)
      + user_data                            = <<-EOT
            #!/bin/bash
            dnf install -y nginx
            echo "<h1>Hello from TerraWeek 2026 🚀</h1>" > /usr/share/nginx/html/index.html
            systemctl enable --now nginx
        EOT
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-07bd746ffcc9a7a4c",
        ]

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)

      + secondary_network_interface (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_id = (known after apply)
  + public_ip   = (known after apply)
  + web_url     = (known after apply)

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```
terraform apply      # type: yes
```text
ata.aws_availability_zones.available: Reading...
data.aws_ami.al2023: Reading...
aws_vpc.main: Refreshing state... [id=vpc-0c80ece1b08345982]
data.aws_availability_zones.available: Read complete after 1s [id=us-east-1]
data.aws_ami.al2023: Read complete after 2s [id=ami-0fd6240f599091088]
aws_internet_gateway.igw: Refreshing state... [id=igw-02f71846055c2bf30]
aws_subnet.public: Refreshing state... [id=subnet-03d46d50fcbf3a512]
aws_security_group.web: Refreshing state... [id=sg-07bd746ffcc9a7a4c]
aws_route_table.public: Refreshing state... [id=rtb-034fff886fa0f35db]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-0f262d2ca18bfaede]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-0fd6240f599091088"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "us-east-1"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = "subnet-03d46d50fcbf3a512"
      + tags                                 = {
          + "Name" = "terraweek-web"
        }
      + tags_all                             = {
          + "Day"       = "03"
          + "ManagedBy" = "terraform"
          + "Name"      = "terraweek-web"
          + "Project"   = "terraweek-2026"
        }
      + tenancy                              = (known after apply)
      + user_data                            = <<-EOT
            #!/bin/bash
            dnf install -y nginx
            echo "<h1>Hello from TerraWeek 2026 🚀</h1>" > /usr/share/nginx/html/index.html
            systemctl enable --now nginx
        EOT
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-07bd746ffcc9a7a4c",
        ]

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)

      + secondary_network_interface (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_id = (known after apply)
  + public_ip   = (known after apply)
  + web_url     = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web: Creating...
aws_instance.web: Still creating... [00m10s elapsed]
aws_instance.web: Creation complete after 17s [id=i-0c1f5f0f48bf02d44]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ami_id = "ami-0fd6240f599091088"
instance_id = "i-0c1f5f0f48bf02d44"
public_ip = "98.86.174.213"
web_url = "http://98.86.174.213"
```
terraform state list # see everything Terraform now manages
```text
ranjeetbhosale@Ranjeets-MacBook-Air example % terraform state list
data.aws_ami.al2023
data.aws_availability_zones.available
aws_instance.web
aws_internet_gateway.igw
aws_route_table.public
aws_route_table_association.public
aws_security_group.web
aws_subnet.public
aws_vpc.main
```

### Task 4: Meta-Arguments in Action
Extend the config to practice each of these:
- **`count`** — create N identical resources (e.g. N EC2 instances).
<br>Added code to count = 2 as below with changes in outputs.tf and main.tf(Name = "${var.name_prefix}-web-${count.index + 1}")
<br>

```diff
diff --git a/day03/example/main.tf b/day03/example/main.tf
index 6cf9b44..0e698ba 100644
--- a/day03/example/main.tf
+++ b/day03/example/main.tf
@@ -105,10 +105,10 @@ resource "aws_security_group" "web" {
 
 resource "aws_instance" "web" {
   ami                    = data.aws_ami.al2023.id
-  count                  = 2
   instance_type          = var.instance_type
   subnet_id              = aws_subnet.public.id
   vpc_security_group_ids = [aws_security_group.web.id]
+  associate_public_ip_address = true
 
   user_data = <<-EOF
     #!/bin/bash
@@ -122,6 +122,6 @@ resource "aws_instance" "web" {
   }
 
   tags = {
-    Name = "${var.name_prefix}-web"
+    Name = "${var.name_prefix}-web-${count.index + 1}"
   }
 }
diff --git a/day03/example/outputs.tf b/day03/example/outputs.tf
index c25bf60..ddd5b32 100644
--- a/day03/example/outputs.tf
+++ b/day03/example/outputs.tf
@@ -1,16 +1,16 @@
-output "instance_id" {
-  description = "ID of the EC2 instance."
-  value       = aws_instance.web.id
+output "instance_ids" {
+  description = "IDs of all EC2 instances."
+  value       = aws_instance.web[*].id
 }
 
-output "public_ip" {
-  description = "Public IP of the web server."
-  value       = aws_instance.web.public_ip
+output "public_ips" {
+  description = "Public IPs of the web servers."
+  value       = aws_instance.web[*].public_ip
 }
 
-output "web_url" {
-  description = "Open this in your browser once the instance boots."
-  value       = "http://${aws_instance.web.public_ip}"
+output "web_urls" {
+  description = "URLs to access the web servers."
+  value       = [for ip in aws_instance.web[*].public_ip : "http://${ip}"]
 }
```

- **`for_each`** — create resources from a `map`/`set` (preferred over `count` for named things).
<br>Added in day03/example_for
- **`depends_on`** — force an explicit ordering.
<br>Code for depends_on added in day03/example_depends_on, demonstrated EC2 instance depends on AWS SG.
<br>Dependency graph is as:

![DTerraform Dependency Graph showing EC2 depending on Security Group](../example_depends_on/graph.png)

- **`lifecycle`** — try `create_before_destroy`, `prevent_destroy`, and `ignore_changes`

```hcl
lifecycle {
  create_before_destroy = true
  ignore_changes        = [tags["LastModified"]]
}
```

### Task 5: Update & Destroy
- Change a `tag` or the `instance_type`, run `terraform plan`, and read the diff — notice what forces **replace** vs **in-place update**.
- **Always** finish with:
```bash
terraform destroy   # type: yes  — avoid surprise bills!
```

---

> 📚 **Reference the companion repo:** study [`examples/for_each.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/examples/for_each.tf) (for_each maps/sets + **dynamic blocks**) and [`examples/lifecycle.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/examples/lifecycle.tf) (all four lifecycle patterns). The real infra in [`ec2.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/ec2.tf) / [`s3.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/s3.tf) / [`dynamodb.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/dynamodb.tf) shows the same concepts on live AWS.

## 🧠 `count` vs `for_each` — which one?
- Use **`count`** for N *identical, interchangeable* resources.
- Use **`for_each`** when each instance has a *stable identity* (a name/key) — deleting one won't reindex the rest.

---

## 🍫 Bonus (Brownie Points)
- Attach an Elastic IP, or add user-data to install Nginx on boot.
- Use `terraform graph` and visualize the dependency graph.
- Try the **`moved`** block to rename a resource without destroying it.

---

## 📤 What to Submit
- Blog / LinkedIn / X post: your `terraform plan`/`apply` output, the AWS console showing your resources, and the diff when you changed something.
- Push to your GitHub repo. Tag **#TrainWithShubham #TerraWeekChallenge**.

---

📺 **Companion video:** [Terraform In One Shot](https://youtu.be/S9mohJI_R34) (Project 1 — EC2, S3, DynamoDB on AWS)
💻 **Companion code:** [`ec2.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/ec2.tf), [`examples/for_each.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/examples/for_each.tf), [`examples/lifecycle.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/examples/lifecycle.tf) · [AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
💬 Questions? [Discord](https://discord.gg/hs3Pmc5F) / [Telegram](https://t.me/trainwithshubham).

### Happy Terraforming! 🌍💻
