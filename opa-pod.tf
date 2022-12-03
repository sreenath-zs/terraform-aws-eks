provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "opa_dep" {
  metadata {
    name = "opa"
    labels = {
      app         = "opa"
      #system-type = "aws-api-gateway"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app         = "opa"
       # system-type = "aws-api-gateway"
      }
    }

    template {
      metadata {
        labels = {
          app         = "opa"
         # system-type = "aws-api-gateway"
        }
      }

      spec {
        container {
          image = "openpolicyagent/opa:0.42.2-envoy-rootless"
          name  = "opa-app"
          port {
            container_port = 8181
          }
          args = ["run",
            "--server",
            "--config-file=/config/conf.yaml",
            "--diagnostic-addr=0.0.0.0:8282",
            "--authorization=basic",
            "--addr=http://127.0.0.1:8181",
            "--ignore=.*"]
          volume_mount {
            mount_path = "/config"
            name       = "opa-config-vol"
            read_only  = true
          }
        }
        volume {
          name = "opa-config-vol"
          config_map {
            name = "opa-config"
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "opa_svc" {
  metadata {
    name = "opa-svc"
    labels = {
      app         = "opa"
      #system-type = "aws-api-gateway"
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }
  spec {
    external_traffic_policy = "Local"
    selector = {
      app         = "opa"
      #system-type = "aws-api-gateway"
    }
    port {
      name        = "http"
      port        = 80
      target_port = 8181
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
}
resource "kubernetes_config_map" "example" {
  metadata {
    name = "opa-config"
  }
  data = {
    "conf.yaml" = <<-EOT
            discovery:
              name: discovery
              service: styra
            labels:
              system-id: b0fa967f370f40f29848e8b7ea669746
              system-type: aws-api-gateway
            services:
            - name: styra
              url: http://slp-aws-gateway-svc:8080/v1
            - name: styra-bundles
              url: http://slp-aws-gateway-svc:8080/v1/bundles
        EOT
  }
}