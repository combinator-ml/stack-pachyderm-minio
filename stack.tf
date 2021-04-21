terraform {
  required_providers {
    provider = {
      source  = "hashicorp/helm"
      version = "~> 2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.10.0"
    }
  }
}

module "minio" {
  source        = "combinator-ml/minio/k8s"
  version       = "0.0.2"
  enable_tenant = true
}

resource "kubernetes_job" "minio_make_buckets_job" {
  metadata {
    labels = {
      app = "minio-make-buckets-job"
    }
    name = "minio-make-buckets-job"
  }
  spec {
    template {
      metadata {
        labels = {
          "app" = "minio-make-buckets-job"
        }
      }
      spec {
        container {
          image = "minio/mc:latest"
          name  = "minio-mc"
          command = [
            "/bin/bash",
            "-ce",
          ]
          env {
            name = "MINIO_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = module.minio.minio_tenant_secret_key_ref
                key  = "accesskey"
              }
            }
          }
          env {
            name = "MINIO_SECRET_KEY"
            value_from {
              secret_key_ref {
                name = module.minio.minio_tenant_secret_key_ref
                key  = "secretkey"
              }
            }
          }
          env {
            name  = "MINIO_ENDPOINT"
            value = module.minio.minio_endpoint
          }
          env {
            name  = "MINIO_PORT"
            value = module.minio.minio_port
          }
          env {
            name  = "BUCKET"
            value = var.pachyderm_bucket_name
          }
          args = [
            <<-EOT
checkBucketExists() {
  ebucket=$1
  CMD=$($MC ls myminio | grep "\s$ebucket/$" > /dev/null 2>&1)
  return $?
}
MC="mc --insecure"
$MC config host add myminio $MINIO_ENDPOINT:$MINIO_PORT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
# Create the bucket if it does not exist
for iBUCKET in $BUCKET
do
  if ! checkBucketExists $iBUCKET; then
    echo "Creating bucket $iBUCKET"
    $MC mb myminio/$iBUCKET
  else
    echo "Bucket $iBUCKET already exists."
  fi
done
EOT
          ]
        }
        restart_policy = "OnFailure"
      }
    }
    backoff_limit = 20
  }
  wait_for_completion = true

  timeouts {
    create = "10m"
    delete = "1m"
  }

  depends_on = [
    module.minio
  ]
}

module "pachyderm" {
  source  = "combinator-ml/pachyderm/k8s"
  version = "0.0.1"
  values = [<<EOT
tls:
  certName: null # Disable TLS
  create: null # Disable TLS
etcd:
  storageClass: local-path
pachd:
  logLevel: debug
  storage:
    backend: AMAZON
    amazon:
      bucket: ${var.pachyderm_bucket_name}
      customEndpoint: ${module.minio.minio_endpoint}:${module.minio.minio_port}
      id: ${module.minio.MINIO_ROOT_USER}
      secret: ${module.minio.MINIO_ROOT_PASSWORD}
      verifySSL: false # Because the certificates aren't verifiable
      region: us-east-1 # This value doesn't matter, but pach needs it.
EOT
  ]

  depends_on = [
    kubernetes_job.minio_make_buckets_job,
  ]
}
