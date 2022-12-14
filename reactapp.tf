provider "kubernetes" {
  config_path    = "~/.kube/config"

}


resource "kubernetes_namespace" "sample-reactapp" {
  metadata {
    name = "sample-reactapp"
  }
}

resource "kubernetes_deployment" "sample-reactapp" {
  metadata {
    name      = "sample-reactapp"
    namespace = kubernetes_namespace.sample-reactapp.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "sample-reactapp"
        system-type: istio
      }
    }
    template {
      metadata {
        labels = {
          app = "sample-reactapp"
          system-type: istio
        }
      }
      spec {
        container {
          image = "sreenathkk96/frontendreact:0.0.17"
          name  = "sample-reactapp-container"
          port {
            container_port = 3000
          }
          env {
              name = "REACT_APP_API_URL"
              value = "http://10.105.181.23:8080/api/v1/employees"  #backend svc ip address"

        }

      }
    }
  }
}
}

resource "kubernetes_service" "sample-reactapp" {
  metadata {
    name      = "sample-reactapp"
    namespace = kubernetes_namespace.sample-reactapp.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.sample-reactapp.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_deployment" "sample-reactapp" {
  metadata {
    name      = "sample-reactapp-Backend"
    namespace = kubernetes_namespace.sample-reactapp.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "sample-reactapp-Backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "sample-reactpp-Backend"
        }
      }
      spec {
        container {
          image = "sreenathkk96/backendspring:0.0.17"
          name  = "sample-reactapp-Backend-container"
          port {
            container_port = 8080
          }
          env {
              name = "DB_SERVER"
              value = "mongo" 

        }

      }
    }
  }
}
}

resource "kubernetes_service" "sample-reactapp" {
  metadata {
    name      = "sample-reactapp-Backend"
    namespace = kubernetes_namespace.sample-reactapp.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.sample-reactapp.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.sample-reactapp.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongo"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          image = "mongo"
          name  = "mongo-container"
          port {
            container_port = 27017
          }
      }
    }
  }
}
}


resource "kubernetes_service" "mongo" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.sample-reactapp.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.mongo.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = 27017
      target_port = 27017
    }
  }
}