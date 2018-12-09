output "service_alb_url" {
  value = "http://${module.nginx.service_url}"
}
