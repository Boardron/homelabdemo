job "pihole" {
  
  datacenters = ["dc1"]
  
  group "pihole" {
    count = 1

    network {
      port "pihole-dns" {
        to = 53
      }
      port "pihole-http" {
        to = 80
      }
      mode = "bridge"
    }

    service {
      name = "pihole-dnsservice"
      port = "pihole-dns"
      provider = "nomad"

      check {
        name     = "pihole-dnsprobe"
        type     = "tcp"
        interval = "10s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.pirouter1.entrypoints=pihole",
        "traefik.tcp.routers.pirouter1.rule=HostSNI(`*`)"
      ]
    }
    
    service {
      name = "pihole-webservice"
      port = "pihole-http"
      provider = "nomad"

      check {
        name     = "pihole-webprobe"
        type     = "http"
        path     = "/admin"
        interval = "10s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.pirouter2.entrypoints=web",
        "traefik.http.routers.pirouter2.rule=PathPrefix(`/admin`)"
      ]
    }

    task "pihole-start" {
      driver = "docker"

      config {
        image = "pihole/pihole"
        ports = ["pihole-dns","pihole-http"]
      }
      resources {
        cpu    = 1000
        memory = 1024
      }
      env {
        WEBPASSWORD = "MyPiHole"
      }
    }
  
  }
}
