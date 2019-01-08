disable_cache = true
disable_mlock = true

storage "file" {
  path = "/path/to/db"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = "1"
}
