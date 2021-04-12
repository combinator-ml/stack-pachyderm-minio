# stack-pachyderm-minio

A combinator stack that combines pachyderm and minio.

## Usage

### Stack Creation

```bash
KUBE_CONFIG_PATH=~/.kube/config terraform apply
```

This will take about five minutes to complete because of the automatic certificate signing process performed by minio.

### Stack Deletion

```bash
KUBE_CONFIG_PATH=~/.kube/config terraform destroy 
```

## Known Issues

- Why do you have to explicitly export the Kubernetes config?

I found that hardcoding the kubeconfig led to [this terraform bug](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234).

- Left over certificate signing requests

The minio automatic signing request feature creates left over CSRs in k8s. You will need to delete these before reinstalling.
