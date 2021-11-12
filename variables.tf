variable "from" {
  description = "The source domain from which we're redirecting."
  type        = string
}

variable "to" {
  description = "The destination domain to which we're redirecting."
  type        = string
}

variable "zone_id" {
  description = "The zone_id for the origin domain."
  type        = string
}
