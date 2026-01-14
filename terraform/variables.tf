# Variables for the Terraform configuration

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "nyctaxi"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "francecentral"
}

variable "postgres_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "citus"
}

variable "postgres_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "start_date" {
  description = "Start date for data ingestion (YYYY-MM format)"
  type        = string
  default     = "2024-01"
}

variable "end_date" {
  description = "End date for data ingestion (YYYY-MM format)"
  type        = string
  default     = "2024-03"
}

variable "allowed_ip_address" {
  description = "Your public IP address to allow PostgreSQL access (optional)"
  type        = string
  default     = ""
}
