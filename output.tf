output "webserver_url" {

  value = "http://${var.hostname}.${var.domain_name}"
}
