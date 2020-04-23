module "networking" {
  source        = "./modules/networking"
  project_name  = var.project_name
  environment = var.environment
  application = var.application
}
