# terraform-k8s-stack-pachyderm-minio

Combinator.ml stack comprising of [Pachyderm](https://github.com/combinator-ml/terraform-k8s-pachyderm) backed by [Minio](https://github.com/combinator-ml/terraform-k8s-minio).

## Usage

```terraform
module "pachyderm-minio-stack" {
  source  = "combinator-ml/pachyderm-minio-stack/k8s"
  version = "0.0.0"
}
```

See the full configuration options below.

### Stack Creation

```bash
KUBE_CONFIG_PATH=~/.kube/config terraform apply
```

### Stack Deletion

```bash
KUBE_CONFIG_PATH=~/.kube/config terraform destroy
```

## Known Issues

- Why do you have to explicitly export the Kubernetes config?

I found that hardcoding the kubeconfig led to [this terraform bug](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234).

## Requirements

| Name | Version |
|------|---------|
| kubectl | ~> 1.10.0 |
| provider | ~> 2.1.0 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| minio | ../minio |  |
| pachyderm | ../pachyderm |  |

## Resources

| Name |
|------|
| [kubernetes_job](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | (Optional) The namespace to install the release into. Defaults to default | `string` | `"default"` | no |
| pachyderm\_bucket\_name | (Optional) the name of the bucket in minio to store Pachyderm data (must be bucket name compliant) | `string` | `"pachyderm-data"` | no |

## Outputs

| Name | Description |
|------|-------------|
| CONSOLE\_ACCESS\_KEY | Minio console username. |
| CONSOLE\_SECRET\_KEY | Minio console password |
| MINIO\_ROOT\_PASSWORD | Minio root password |
| MINIO\_ROOT\_USER | Minio root username. |
| tenant\_namespace | Namespace is the kubernetes namespace of the minio operator. |
