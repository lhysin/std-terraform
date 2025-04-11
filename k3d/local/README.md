# k3d with Terraform locally

<br>

## 사전 설치

---

### Docker

* [Docker Install](https://docs.docker.com/engine/install/)

### Terraform
* [Terraform install cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

macos
```bash
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/terraform
```

### k3d

* [k3d install](https://k3d.io/stable/#installation)

any os
```bash
$ wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# or

$ curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

<br>

## terraform apply

---

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

