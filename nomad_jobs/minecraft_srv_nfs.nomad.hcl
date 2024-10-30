job "minecraft_nfs" {
  
  datacenters = ["dc1"]
  
  group "mc" {
    
    volume "mc_data" {
      type      = "csi"
      read_only = false
      source    = "nfs_mc"
      attachment_mode = "file-system"
      access_mode = "multi-node-multi-writer"
    }

    network {
      port "mc-vanilla-port" {
        to = 25565
      }
      port "mc-vanilla-rcon" {
        to = 25575
        static = 25575
      }
      mode = "bridge"
    }

    service {
      name = "mc-service"
      port = "mc-vanilla-port"
      provider = "nomad"

      check {
        name     = "mc_probe"
        type     = "tcp"
        interval = "10s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.mcrouter1.entrypoints=minecraft",
        "traefik.tcp.routers.mcrouter1.rule=HostSNI(`*`)"
      ]
    }

    task "minecraft-server-start" {
      driver = "docker"

      volume_mount {
        volume      = "mc_data"
        destination = "/data"
        read_only   = false
      }

      config {
        image = "itzg/minecraft-server"
        ports = ["mc-vanilla-port","mc-vanilla-rcon"]
      }
      resources {
        cpu    = 8000
        memory = 8192
      }
      env {
        EULA = "TRUE"
      } 
    }
  
  }
}
