type = "csi"
id = "nfs_mc"
name = "nfs_mc"
plugin_id = "nfs"

capability {
  access_mode = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode = "single-node-writer"
  attachment_mode = "file-system"
}

context {
  server = "192.168.1.224"
  share = "/srv/nfs/mc_data"
}

mount_options {
  fs_type = "nfs"
} 
