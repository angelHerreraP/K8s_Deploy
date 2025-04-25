resource "kubernetes_secret" "wordpress_db" {
  metadata {
    name = "wordpress-db-secret"
  }
  data = {
    WORDPRESS_DB_HOST     = aws_db_instance.wordpress.endpoint
    WORDPRESS_DB_USER     = aws_db_instance.wordpress.username
    WORDPRESS_DB_PASSWORD = aws_db_instance.wordpress.password
    WORDPRESS_DB_NAME     = "wordpress"
  }
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
          image = "wordpress:php8.1-apache"

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
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
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