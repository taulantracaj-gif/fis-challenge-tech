resource "helm_release" "nodeapp" {
  name      = "nodeapp"
  provider  = helm.aks
  chart     = "C:/HLK/fis_tr_infra/02-Task-3-Helm/nodeapp" # Path to your Helm chart
  namespace = var.namespace


  set {
    name  = "image.repository"
    value = var.docker_image_repository
  }
  set {
    name  = "image.tag"
    value = var.image_tag # Pass the image tag from Terraform variable
  }

  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  set {
    name  = "autoscaling.enabled"
    value = true
  }

  set {
    name  = "autoscaling.minReplicas"
    value = var.replica_count
  }

  set {
    name  = "autoscaling.maxReplicas"
    value = var.max_replicas
  }

  set {
    name  = "autoscaling.targetCPUUtilizationPercentage"
    value = var.target_cpu_utilization
  }

  set {
    name  = "autoscaling.targetCPUUtilizationPercentage"
    value = var.target_cpu_utilization
  }

  set {
    name  = "ingress.hosts[0].host"
    value = "${var.hostname_prefix}.${var.domain}"
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "${var.hostname_prefix}.${var.domain}"
  }

  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
  }

  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }

  set {
    name  = "nodeSelector.${var.node_selector_key}"
    value = var.node_selector_value
  }

  set {
    name  = "env.APP_NAME"
    value = var.APP_NAME
  }

  set {
    name  = "env.ENVIRONMENT"
    value = var.environment
  }

  values = [
    "${file("${path.module}/helm_values/custom-values.yml")}"
  ]
  # values = [
  #   "${file("${path.module}/helm_values/values.yaml")}"
  # ]
}
