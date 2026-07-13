# 🧩 TerraWeek Day 2 — HCL Deep Dive: Variables, Types & Expressions

**Date:** Monday, 13th July 2026

Yesterday you ran your first `apply`. Today you'll learn the **language** behind it — **HCL (HashiCorp Configuration Language)** — so your configs become flexible, reusable, and readable. ✍️

---

## 🎯 Learning Goals

- Understand HCL **blocks, arguments, and expressions**.
- Use **input variables** with types, defaults, validation, and `sensitive`.
- Use **`locals`**, **`outputs`**, and built-in **functions**.
- Understand **variable precedence** (`tfvars`, `-var`, env vars).

---

# Terraform Notes: Master HCL Syntax

## 📝 Tasks

### Task 1: Master HCL Syntax

Explain (with examples) in your notes:
* The anatomy of a **block**: `block_type "label_one" "label_two" { argument = value }`.
* The difference between an **argument** and a **block**.
* **Expressions**: string interpolation `"${...}"`, references (`resource.name.attr`), and operators.

---

#### The Anatomy of a Block

Blocks are containers for other content and usually represent the configuration of some kind of object, like a resource. Most of Terraform's features are controlled by top-level blocks in a configuration file. 

Blocks have a block type, can have zero or more labels, and have a body that contains any number of arguments and nested blocks.

##### Syntax Template

```hcl
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  # Block body
  <IDENTIFIER> = <EXPRESSION> # Argument
}
```

##### Real-World Example

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}
```

* **Block Type (`resource`)**: Identifies the kind of infrastructure object Terraform should manage.
* **Block Label 1 (`"aws_vpc"`)**: Specifies the resource provider and type.
* **Block Label 2 (`"main"`)**: The user-defined local name used to reference this specific block elsewhere.
* **Block Body**: Everything enclosed within the curly braces `{}`.
* **Identifier/Argument (`cidr_block`)**: A specific configuration parameter accepted by the block.
* **Expression (`var.base_cidr_block`)**: Represents the value assigned to the identifier.

---

#### The Difference Between an Argument and a Block

The fundamental difference is that an **argument** sets a specific value, while a **block** creates a new structural object or container.

##### Visual Comparison

```hcl
resource "aws_instance" "web" {
  # ARGUMENT: Sets a specific setting using the '=' sign
  instance_type = "t3.micro" 

  # BLOCK: Creates a nested configuration object using curly braces '{ }' without '='
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}
```

##### Key Differences

* **Arguments**: Assign a value to a name. They appear strictly within blocks and use the equals sign (`=`) for assignment. They can only be defined once per block scope.
* **Blocks**: Act as structural wrappers. They can be top-level objects or nested inside other blocks to form child objects. Certain blocks can be repeated multiple times (such as multiple `ingress` blocks inside a security group).

---

#### Expressions

Expressions represent a value, either literally or by referencing and combining other values. They appear as values for arguments, or within other expressions.

##### 1. String Interpolation
String interpolation allows you to insert dynamic expressions directly into literal strings using the `${...}` syntax.

```hcl
variable "project_name" {
  default = "ecommerce"
}

# Result evaluates to "ecommerce-public-bucket"
resource "aws_s3_bucket" "bucket" {
  bucket = "\${var.project_name}-public-bucket"
}
```

##### 2. References
References allow you to read attributes from other objects in your Terraform state. You connect objects using dot-notation (`type.name.attribute`).

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Accesses the 'id' attribute from the VPC resource block above
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

##### 3. Operators
Operators manipulate and evaluate values. They are grouped into arithmetic, comparison, logical, and conditional types.

* **Conditional (Ternary)**: Evaluates a boolean condition. If true, returns the first value; if false, returns the second.
  ```hcl
  # If var.is_prod is true, size is 100. Otherwise, it is 20.
  volume_size = var.is_prod ? 100 : 20
  ```
* **Arithmetic**: Performs basic math calculations.
  ```hcl
  disk_size = 20 * var.size_multiplier
  ```
* **Logical & Comparison**: Combines or tests conditions to return `true` or `false`.
  ```hcl
  # Evaluates to true only if both conditions are met
  enable_monitoring = var.env == "prod" && var.detailed_metrics == true
  ```



### Task 2: Variables, Types & Validation
Create a `variables.tf` and define variables covering **each major type**:
- Primitives: `string`, `number`, `bool`
- Collections: `list(string)`, `map(string)`, `set(string)`
- Structural: `object({...})`, `tuple([...])`

Add at least one variable with:
- a **`default`**,
- a **`validation`** block (e.g. only allow certain values),
- the **`sensitive = true`** flag.

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
```
### Task 2: Variables, Types & Validation

Create a `variables.tf` and define variables covering **each major type**:
* Primitives: `string`, `number`, `bool`
* Collections: `list(string)`, `map(string)`, `set(string)`
* Structural: `object({...})`, `tuple([...])`

Add at least one variable with:
* a **`default`**,
* a **`validation`** block (e.g. only allow certain values),
* the **`sensitive = true`** flag.

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
```

---

#### Complete Code Implementation (`variables.tf`)

```hcl
# ==============================================================================
# PRIMITIVE TYPES
# ==============================================================================

# Note: The "environment" variable with validation is defined above.

variable "instance_count" {
  description = "Number of EC2 instances to provision"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "The instance count must be between 1 and 10."
  }
}

variable "enable_termination_protection" {
  description = "If true, enables delete protection on critical resources"
  type        = bool
  default     = false
}

# ==============================================================================
# COLLECTION TYPES
# ==============================================================================

variable "availability_zones" {
  description = "An ordered list of target availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "resource_tags" {
  description = "A map of default key-value pairs to apply to resources"
  type        = map(string)
  default = {
    Project   = "eCommerce"
    ManagedBy = "Terraform"
  }
}

variable "unique_dns_servers" {
  description = "A set of unique IP addresses for custom DNS"
  type        = set(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# ==============================================================================
# STRUCTURAL TYPES
# ==============================================================================

variable "database_config" {
  description = "A strict schema object grouping related configuration parameters"
  type = object({
    engine           = string
    port             = number
    allocated_gb     = number
    backup_retention = number
  })
  default = {
    engine           = "postgres"
    port             = 5432
    allocated_gb     = 20
    backup_retention = 7
  }
}

variable "network_subnets" {
  description = "A fixed-length sequence of different types (tuple) representing tier properties"
  type        = tuple([string, number, bool])
  default     = ["10.0.1.0/24", 80, true]
}

# ==============================================================================
# SENSITIVE VARIABLE WITH VALIDATION & DEFAULT
# ==============================================================================

variable "db_password" {
  description = "The master password for the application database"
  type        = string
  default     = "SuperSecurePassword123!"
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "The database password must be at least 12 characters long."
  }
}
```

#### Key Architecture Concepts

##### Collections vs. Structural Types
* **Collections** (`list`, `map`, `set`) require every internal element to be the exact same data type.
* **Structural Types** (`object`, `tuple`) allow you to mix and match multiple disparate data types into a single complex schema.

##### The Sensitive Flag Limitation
Setting `sensitive = true` prevents values from being printed directly into the shell stdout during `terraform plan` or `terraform apply`. However, this data is still saved as **unencrypted plain text inside your `.tfstate` file**. You must always protect state backends using remote access controls and encryption at rest.



### Task 3: Locals, Outputs & Functions
- Use a **`locals`** block to compute a value (e.g. a common `name_prefix` or merged tags).
- Add **`outputs`** that expose useful values.
- Use at least **3 built-in functions** — e.g. `upper()`, `merge()`, `join()`, `lookup()`, `length()`, `format()`.
  Explore them live with `terraform console`:
```bash
terraform console
> upper("terraweek")
> merge({a=1}, {b=2})
> join("-", ["tws", "terraweek", "2026"])
```



#### Interactive Exploration (`terraform console`)

Before defining blocks, explore function evaluation live in your terminal:

```bash
terraform console
> upper("terraweek")
"TERRAWEEK"

> merge({a=1}, {b=2})
{
  "a" = 1
  "b" = 2
}

> join("-", ["tws", "terraweek", "2026"])
"tws-terraweek-2026"
```

---

#### Code Implementation

##### 1. Local Values Block (`locals.tf`)

```hcl
locals {
  # Built-in Function 1: upper() - Normalizes string to uppercase
  env_upper = upper(var.environment)

  # Built-in Function 2: format() - Constructs a standardized naming prefix
  name_prefix = format("tws-%s-%s", lower(var.project_name), var.environment)

  # Built-in Function 3: merge() - Combines default tags with dynamic, resource-specific tags
  common_tags = merge(
    var.resource_tags,
    {
      Environment = local.env_upper
      ManagedBy   = "Terraform"
      CreatedAt   = "2026-07-13" # Current tracking timestamp
    }
  )

  # Built-in Function 4: length() - Evaluates sizing for metric collection dynamically
  az_count = length(var.availability_zones)
}
```

##### 2. Outputs Block (`outputs.tf`)

```hcl
output "resource_prefix" {
  description = "The computed naming prefix applied to infrastructure components"
  value       = local.name_prefix
}

output "global_tags" {
  description = "The fully aggregated map of resource tags"
  value       = local.common_tags
}

output "deployment_summary" {
  description = "A formatted text snippet detailing target deployment sizing"
  # Built-in Function 5: join() - Flattens an array into a clean layout string
  value       = "Deploying to \${local.env_upper} across \({local.az_count} zones:\){join(", ", var.availability_zones)}"
}

output "secure_db_endpoint" {
  description = "The database connections context string"
  value       = "Database running on port \${var.database_config.port}"
}
```

---

#### Key Architecture Concepts

##### Why use Locals?
Local values function like temporary constants within an application. They allow you to centralize messy expression duplication or complex formatting into a single managed string. This ensures your resource blocks remain readable.

##### What makes Outputs essential?
Outputs serve two major structural tasks:
1. **CLI Visibility:** Exposing critical resource IDs, endpoints, or properties to human engineers directly inside the command line tool pipeline.
2. **State Sharing:** Passing calculated platform secrets or networking maps downstream into entirely separate configurations utilizing `terraform_remote_state` data lookups.

---

### Task 4: Build Something Real (Docker provider — no cloud cost)
Use the **starter code in [`./example`](./example)**. It uses the **`kreuzwerker/docker`** provider to pull an Nginx image and run a container — fully driven by variables.

> 🐳 **Prereq:** Docker installed and running. Prefer cloud? Swap the Docker resources for a `local_file` driven by your variables — the HCL concepts are identical.

```bash
cd example
terraform init
terraform plan  -var 'container_name=tws-web' -var 'external_port=8082'
terraform apply -var 'container_name=tws-web' -var 'external_port=8082'
# visit http://localhost:8080
terraform output
terraform destroy -var 'container_name=tws-web' -var 'external_port=8082'
```
<br><img width="981" height="825" alt="image" src="https://github.com/user-attachments/assets/af7b4edc-e10a-4c13-8381-39e5ad60635e" />
<br><img width="1054" height="534" alt="image" src="https://github.com/user-attachments/assets/71755bed-728a-4c69-adf5-dd6901029112" />
<br><img width="983" height="683" alt="image" src="https://github.com/user-attachments/assets/bbc5e06c-1ae0-44ec-b687-7316f08c0348" />
<br><img width="840" height="751" alt="image" src="https://github.com/user-attachments/assets/1ca6792b-50f0-4566-8fd5-4bd4a5a3fb33" />
<br><img width="1032" height="322" alt="image" src="https://github.com/user-attachments/assets/7021996d-c2cf-47a4-b1b9-bb578e6887ea" />
<br>terraform output
<br><img width="462" height="66" alt="image" src="https://github.com/user-attachments/assets/78d82637-2614-427e-91f8-3be4bbec4b4a" />
<br>terraform destroy -var 'container_name=tws-web' -var 'external_port=8082'
<br><img width="979" height="827" alt="image" src="https://github.com/user-attachments/assets/acc6b4bd-1bf0-4e1a-b96b-1869600d6985" />

  <br>Then try the same run using a **`terraform.tfvars`** file instead of `-var` flags and note the difference.
<br>terrform plan
<br><img width="979" height="658" alt="image" src="https://github.com/user-attachments/assets/e72b4ff4-90fc-4c69-9461-0d5a54fcc437" />
<br><img width="1050" height="764" alt="image" src="https://github.com/user-attachments/assets/4d6a0a31-a9ad-4457-9f5b-9d95e317c6b6" />
<br>terraform apply
<br><img width="981" height="667" alt="image" src="https://github.com/user-attachments/assets/2c4ba311-68d1-49f5-948f-cc5257ed6fcc" />
<br><img width="389" height="792" alt="image" src="https://github.com/user-attachments/assets/7d8ad6ba-4990-429b-afd1-254bb1e3dfe5" />
<br><img width="998" height="218" alt="image" src="https://github.com/user-attachments/assets/d1f92088-fa6f-47d5-a795-f3356b5510e9" />
<br><img width="998" height="218" alt="image" src="https://github.com/user-attachments/assets/7d46aec2-3325-4639-834b-847905560e69" />


---

## 📊 Variable Precedence (highest wins)
```
-var / -var-file  ▶  *.auto.tfvars  ▶  terraform.tfvars  ▶  TF_VAR_ env vars  ▶  default
```
### Task 4: Variable Precedence & Overrides

Understand the hierarchy of evaluation when a single input variable is assigned across multiple configuration points.

#### 📊 Variable Precedence (highest wins)

```text
-var / -var-file  ▶  *.auto.tfvars  ▶  terraform.tfvars  ▶  TF_VAR_ env vars  ▶  default
```

---

#### The Experiment: Command Flags vs. `.tfvars`

To test how variable values are collected and overwritten, execute consecutive deployment plans using the input variable `environment`.

##### Step 1: Run with Command Line Flags
Run a plan passing an explicit setting directly into the terminal window via the CLI flag:

```bash
terraform plan -var="environment=production-cli"
```

* **Observed CLI Behavior**: Terraform overrides your code block's `default = "dev"` parameter and applies `production-cli` to all local dependencies.

##### Step 2: Run with a `terraform.tfvars` File
Create a file named exactly `terraform.tfvars` inside your root project directory:

```hcl
# terraform.tfvars
environment = "staging-tfvars"
```

To run the same plan using your file configuration instead of the CLI flag, execute this command:

```bash
terraform plan
```

* **Observed CLI Behavior**: You no longer need to pass flags to the command line. Terraform automatically parses the file named `terraform.tfvars` at runtime, evaluates its keys, and resolves the value of `environment` to `staging-tfvars`.

##### The Difference
* **Automation**: The `-var` flag requires you to manually type or script inputs into every execution command. The `terraform.tfvars` file is discovered automatically by Terraform without any extra flags.
* **Precedence Collision**: If you run both together (`terraform plan -var="environment=production-cli"` while the file exists), the `-var` flag wins. Command-line flags hold a higher priority and override file declarations.


---

## 🍫 Bonus (Brownie Points)
- Add a **`for` expression** to transform a list/map (e.g. `[for s in var.names : upper(s)]`).
- Use a **conditional expression**: `var.environment == "prod" ? "t3.medium" : "t3.micro"`.
- Try **`optional()`** attributes inside an `object` type.

---

## 📤 What to Submit
- Blog / LinkedIn / X post: your `variables.tf`, a `terraform console` screenshot, and your running container/output.
- Push to your GitHub repo. Tag **#TrainWithShubham #TerraWeekChallenge**.

---

📺 **Companion video:** [Terraform In One Shot](https://youtu.be/S9mohJI_R34) (HCL, variables & validation)
💻 **Companion code:** [`examples/validation.tf`](https://github.com/LondheShubham153/terraform-for-devops/blob/main/examples/validation.tf) — 5 real validation patterns · [Config Language docs](https://developer.hashicorp.com/terraform/language)
💬 Questions? [Discord](https://discord.gg/hs3Pmc5F) / [Telegram](https://t.me/trainwithshubham).

### Happy Terraforming! 🌍💻
