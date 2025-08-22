terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespace
resource "kubernetes_namespace" "bmi" {
  metadata {
    name = "bmi-ns"
  }
}

# Deployment
resource "kubernetes_manifest" "bmi_deploy" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "bmi-deploy"
      namespace = kubernetes_namespace.bmi.metadata[0].name
      labels = {
        app = "bmi"
      }
    }
    spec = {
      replicas = 2
      selector = {
        matchLabels = {
          app = "bmi"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "bmi"
          }
        }
        spec = {
          containers = [
            {
              name  = "bmi-container"
              image = "bmi-app:latest" # Make sure this image is in DockerHub or your local registry
              ports = [
                {
                  containerPort = 5000
                }
              ]
            }
          ]
        }
      }
    }
  }
}

# Service
resource "kubernetes_manifest" "bmi_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "bmi-service"
      namespace = kubernetes_namespace.bmi.metadata[0].name
    }
    spec = {
      selector = {
        app = "bmi"
      }
      ports = [
        {
          protocol   = "TCP"
          port       = 80         # External service port
          targetPort = 5000       # Maps to containerPort
        }
      ]
      type = "ClusterIP"
    }
  }
}

# Ingress
resource "kubernetes_manifest" "bmi_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "bmi-ingress"
      namespace = kubernetes_namespace.bmi.metadata[0].name
      annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      }
    }
    spec = {
      ingressClassName = "nginx"
      rules = [
        {
          host = "localhost"
          http = {
            paths = [
              {
                path     = "/bmi"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "bmi-service"
                    port = {
                      number = 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}
