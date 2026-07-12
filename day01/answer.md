# 🌱 TerraWeek Day 1 — Introduction to IaC & Terraform Basics

**Date:** Sunday, 12th July 2026

Welcome to **Day 1** of the TerraWeek Challenge! Today is all about **foundations** — understanding *why* Infrastructure as Code exists, installing the **latest Terraform (v1.15.x)**, and running your very first `terraform apply`. 🚀

---

## 🎯 Learning Goals

By the end of today you should be able to:
- Explain what **Infrastructure as Code (IaC)** is and why it matters.
- Describe what **Terraform** is and how it fits into the DevOps workflow.
- Install Terraform and verify it works.
- Understand the **core Terraform workflow** and key terminology.
- Provision your **first resource** — with zero cloud cost.

---

## 📝 Tasks

### Task 1: Understand IaC & Terraform
Write short answers (in your blog/notes) to:
- What is **Infrastructure as Code**, and what problems does it solve compared to clicking around a cloud console?
   * **Infrastructure as Code (IaC)** is the practice of provisioning and managing infrastructure using machine-readable configuration files rather than manual, interactive tools.
  * It solves the issues of human error, configuration drift, and inconsistency by letting you define a desired state that the tool automatically configures.
  * This eliminates manual effort, accelerates deployment speeds, and ensures environments are reliably repeatable.

- What is **Terraform**, and why is it so popular? (Hint: declarative, provider-agnostic, huge ecosystem.)
  * **Terraform** is an open-source IaC tool used for building, changing, and versioning infrastructure safely and efficiently.
  * It is **declarative**, meaning you write code to describe your desired end-state infrastructure, and Terraform handles the underlying logic to achieve it.
  * It is **provider-agnostic**, which prevents vendor lock-in. You use the exact same HashiCorp Configuration Language (HCL) syntax and workflow whether you are managing AWS, Azure, GCP, or other platforms.
  * It has a **huge ecosystem** with native support for thousands of providers, allowing you to manage everything from cloud hardware to SaaS tools in one place.
 
- **Terraform vs alternatives** — write one line each on how Terraform compares to **OpenTofu**, **Pulumi**, **CloudFormation**, and **Ansible**.
* **OpenTofu**: A truly open-source, community-driven fork of Terraform created after HashiCorp changed its license to business-friendly BSL.
* **Pulumi**: An IaC tool that allows you to define infrastructure using standard programming languages like Python, TypeScript, or Go instead of custom configuration text.
* **CloudFormation**: A vendor-locked IaC service built natively for AWS, making it highly reliable for Amazon's ecosystem but completely useless for other cloud providers.
* **Ansible**: A procedural configuration management tool optimized for installing software and managing OS-level settings on existing servers, rather than provisioning the foundational cloud hardware itself.

### Task 2: Install Terraform (latest version)
- Install **Terraform ≥ 1.15** using the [official install guide](https://developer.hashicorp.com/terraform/install).
- Verify your install and **paste the output** in your notes:
<br><img width="552" height="708" alt="image" src="https://github.com/user-attachments/assets/8b4c552e-aed1-4d1b-8343-b66fed481150" />

```bash
terraform version
terraform -help
```
- Install the **HashiCorp Terraform** extension in VS Code for syntax highlighting and autocomplete.
<br><img width="685" height="243" alt="image" src="https://github.com/user-attachments/assets/ee176a38-9117-47bd-83a9-c10e66db536c" />

### Task 3: Learn 6 Crucial Terraform Terminologies
Explain each of these **in your own words** with a one-line example:
1. **Provider** — a plugin that lets Terraform talk to a platform (AWS, Azure, Docker…).
2. **Resource** — a piece of infrastructure you want to create (an EC2 instance, an S3 bucket…).
3. **State** — Terraform's record of what it manages (the `terraform.tfstate` file).
4. **Plan** — a preview of the changes Terraform will make.
5. **HCL** — HashiCorp Configuration Language, the syntax you write Terraform in.
6. **Module** — a reusable, packaged group of Terraform configuration. A pre-made folder of code that bundles multiple resources together so you can reuse them easily.
<br>*Example*: Using a single "website package" module to set up a server, database, and security guard all at once.

### Task 4: Your First Terraform Config (no cloud account needed!)
Use the **starter code in [`./example`](./example)** — it uses the `local` and `random` providers, so it costs **nothing** and needs **no credentials**.

Run the **core Terraform workflow** and capture the output of each step:
bash
cd example
<br>terraform init      # download providers, initialize the working directory
<br><img width="581" height="378" alt="image" src="https://github.com/user-attachments/assets/8835e431-631f-4e11-bcff-cfc94af94cb1" />

<br>terraform fmt       # format your code
<br><img width="491" height="83" alt="image" src="https://github.com/user-attachments/assets/9ea0473a-32ba-4e63-a69b-bb80ad632e5e" />

<br>terraform validate  # check for syntax errors
<br><img width="463" height="37" alt="image" src="https://github.com/user-attachments/assets/1ac3770f-3613-450d-8685-2954c7da4232" />

<br>terraform plan      # preview what will be created
<br><img width="862" height="607" alt="image" src="https://github.com/user-attachments/assets/ef73a838-cc8d-4ef6-9c36-d8c2eb0145bd" />

<br>terraform apply     # create the resources (type: yes)
<br><img width="846" height="883" alt="image" src="https://github.com/user-attachments/assets/3adb07f2-29ad-4306-8f82-c976c59bb6f6" />

<br>cat greeting.txt    # see the file Terraform generated
<br><img width="454" height="113" alt="image" src="https://github.com/user-attachments/assets/2bb6eecd-a44a-447e-a87a-8cd0326364ac" />

<br>terraform destroy   # clean up (type: yes)
<br><img width="1198" height="791" alt="image" src="https://github.com/user-attachments/assets/3159d6a8-9c4d-4b78-9276-5ce99206391b" />

---

## 🔁 The Core Terraform Workflow


  Write  ──▶  Init  ──▶  Plan  ──▶  Apply  ──▶  Destroy
  (.tf)     (init)     (preview)   (create)    (clean up)


---

## 🍫 Bonus (Brownie Points)
- Set up **tab completion** for the Terraform CLI: `terraform -install-autocomplete`.
  **CLI Autocomplete**: A quick terminal setup command that enables tab-completion for all Terraform subcommands and flags.
  * *Example*: Running `terraform -install-autocomplete` in your terminal so you can press `Tab` to automatically finish commands like `terraform pl[TAB]` into `terraform plan`.

- Try **[OpenTofu](https://opentofu.org/)** (the open-source fork) and note the differences.
- Explore the `.terraform.lock.hcl` lock file that gets created — what is it for?
  <br><img width="538" height="675" alt="image" src="https://github.com/user-attachments/assets/cabd61bd-a391-41a6-810c-6a4d19fa3409" />
  <br>* **Dependency Lock File (`.terraform.lock.hcl`)**: A file that locks the exact versions and security hashes of your provider plugins to guarantee that your infrastructure deploys the same way on every machine.
  * *What it is for*: It prevents unexpected updates from breaking your code by forcing everyone on your team (and your automation pipelines) to use the exact same provider versions.
  * *Example*: It records that your project uses AWS provider version `v5.30.0` along with its secure checksum, ensuring Terraform never automatically upgrades to a newer version without your permission.


---

## 📤 What to Submit
- A blog / LinkedIn / X post with your learnings + screenshots of `terraform version` and a successful `apply`/`destroy`.
- Push your code to your own **GitHub repo**.
- Tag **#TrainWithShubham #TerraWeekChallenge** and share with your network.

---

📺 **Companion video:** [Terraform In One Shot](https://youtu.be/S9mohJI_R34) (watch the intro + install section)
💻 **Companion code:** [terraform-for-devops](https://github.com/LondheShubham153/terraform-for-devops) — start with its [README](https://github.com/LondheShubham153/terraform-for-devops#readme)
💬 Stuck? Ask in the [Discord](https://discord.gg/hs3Pmc5F) / [Telegram](https://t.me/trainwithshubham) community.

### Happy Terraforming! 🌍💻
