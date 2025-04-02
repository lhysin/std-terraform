variable "tenancy_ocid" {
  description = "OCI 테넌시(tenancy) OCID"
  type        = string
}

variable "user_ocid" {
  description = "OCI 유저(사용자) OCID"
  type        = string
}

variable "private_key" {
  description = "OCI API 키의 private key"
  type        = string
}

variable "fingerprint" {
  description = "OCI API 키의 Fingerprint"
  type        = string
}

variable "region" {
  description = "OCI 리전"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH 접속을 위한 공개 키 경로"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH 접속을 위한 미공개 키 경로"
  type        = string
  default     = "/Users/lhysin/Development/KEYS/ssh-key/ssh-key-2022-09-27.key.pub"
}