job "pihole" {
  
  datacenters = ["dc1"]
  
  group "pihole" {
    count = 1

    volume "pi_data" {
      type      = "csi"
      read_only = false
      source    = "nfs_pi"
      attachment_mode = "file-system"
      access_mode = "multi-node-multi-writer"
    }

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
        interval = "20s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.pirouter1.entrypoints=pihole",
        "traefik.udp.routers.udppirouter1.entrypoints=piholeUDP",
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

      volume_mount {
        volume      = "pi_data"
        destination = "/etc/pihole"
        read_only   = false
      }

      config {
        image = "pihole/pihole"
        ports = ["pihole-dns","pihole-http"]
      }
      resources {
        cpu    = 2000
        memory = 1024
      }
    }
  
  }
}
