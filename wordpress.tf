resource "kubernetes_secret" "wordpress_db" {
  metadata {
    name = "wordpress-db-secret"
  }

  data = {
    WORDPRESS_DB_HOST     = aws_db_instance.wordpress.endpoint
    WORDPRESS_DB_USER     = "administrador"
    WORDPRESS_DB_PASSWORD = "admin123456789"
    WORDPRESS_DB_NAME     = "wordpress"
  }

  depends_on = [aws_db_instance.wordpress]
}



resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "bitnami/wordpress:latest" # Imagen estable

          env_from {
            secret_ref {
              name = kubernetes_secret.wordpress_db.metadata[0].name
            }
          }

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "1000m"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }
      }
    }
  }
}


resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
  }

  spec {
    selector = {
      app = kubernetes_deployment.wordpress.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
    load_balancer_source_ranges = var.allowed_cidr_blocks
  }
}