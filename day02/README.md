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

### Task 4: Build Something Real (Docker provider — no cloud cost)
Use the **starter code in [`./example`](./example)**. It uses the **`kreuzwerker/docker`** provider to pull an Nginx image and run a container — fully driven by variables.

> 🐳 **Prereq:** Docker installed and running. Prefer cloud? Swap the Docker resources for a `local_file` driven by your variables — the HCL concepts are identical.

```bash
cd example
terraform init
terraform plan  -var 'container_name=tws-web' -var 'external_port=8080'
terraform apply -var 'container_name=tws-web' -var 'external_port=8080'
# visit http://localhost:8080
terraform output
terraform destroy -var 'container_name=tws-web' -var 'external_port=8080'
```

Then try the same run using a **`terraform.tfvars`** file instead of `-var` flags and note the difference.

---

## 📊 Variable Precedence (highest wins)
```
-var / -var-file  ▶  *.auto.tfvars  ▶  terraform.tfvars  ▶  TF_VAR_ env vars  ▶  default
```

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
