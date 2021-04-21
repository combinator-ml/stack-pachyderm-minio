# terraform-k8s-stack-pachyderm-minio

Combinator.ml stack comprising of [Pachyderm](https://github.com/combinator-ml/terraform-k8s-pachyderm) backed by [Minio](https://github.com/combinator-ml/terraform-k8s-minio).

## Usage

This could be used as a module, but it is intended as a self-contained stack.

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

- Left over `CertificateSigningRequests`

If you see errors about pods not being able to mouht TLS secrets, it's probably because it's trying to reuse an old set of secrets set up in a previous CertificateSigningRequest. Delete all the old CertificateSigningRequests and try again.

```bash
kubectl delete certificatesigningrequests.certificates.k8s.io minio-tenant-default-csr minio-tenant-console-default-csr
```

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
| minio | combinator-ml/minio/k8s | 0.0.2 |
| pachyderm | combinator-ml/pachyderm/k8s | 0.0.1 |

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
