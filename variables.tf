variable "domains" {
  description = "Domains for which we handle basic redirection."
  type        = set(string)
  default     = []
}

variable "alias_domains" {
  description = "Domains which redirect to another."
  type        = map(string)
  default     = {}
}
