job "nexus" {
  type = "service"

  group "nexus" {
    count = 1

    volume "nx_data" {
      type      = "csi"
      read_only = false
      source    = "nfs_nx"
      attachment_mode = "file-system"
      access_mode = "multi-node-multi-writer"
    }

    network {
      port "nexus-http"{
        to = 8081
      }
      mode = "bridge"
    }

    service {
      name = "nexus-web"
      port = "nexus-http"
      provider = "nomad"

      check {
        name     = "nexus-httpprobe"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.nxrouter1.entrypoints=nexus",
        "traefik.http.routers.nxrouter1.rule=PathPrefix(`/`)"
      ]
    }

    task "nexus" {
      driver = "docker"

      volume_mount {
        volume      = "nx_data"
        destination = "/nexus-data"
        read_only   = false
      }

      config {
        image = "sonatype/nexus3"
        ports = ["nexus3-http"]
      }

      restart {
        attempts = 10
        interval = "5m"
        delay = "25s"
        mode = "delay"
      }
      resources {
        cpu     = 2000
        memory  = 4096
      }
    }
  } 
}
