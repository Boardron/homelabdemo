job "keycloak" {
  type = "service"

  group "keycloak" {
    count = 1

    network {
      port "keycloak-http"{
        to = 8080
      }
      mode = "bridge"
    }

    service {
      name = "keycloak-web"
      port = "keycloak-http"
      provider = "nomad"

      check {
        name     = "keycloak-httpprobe"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.kcrouter1.entrypoints=keycloak",
        "traefik.http.routers.kcrouter1.rule=PathPrefix(`/`)"
      ]
    }

    task "Keycloak" {

      driver = "docker"
      config {
        image = "keycloak/keycloak"
        ports = ["keycloak-http"]
        args  = ["start-dev"]
      }

      resources {
        cpu = 1000
        memory = 1024
      }
      env {
        KC_BOOTSTRAP_ADMIN_USERNAME = "admin"
        KC_BOOTSTRAP_ADMIN_PASSWORD = "admin"
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

  }
  } 
}
