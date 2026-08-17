variable "endpoint" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type      = string
  sensitive = true
}
variable "github_runner_pat" {
}
