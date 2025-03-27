resource "gitlab_project" "k8s-fluxcd" {
  name        = "k8s-fluxcd"
  description = "This is testproject to test fluxcd."

  initialize_with_readme = true
  visibility_level       = "private"
}

resource "flux_bootstrap_git" "uni-dev" {
  depends_on = [gitlab_project.k8s-fluxcd]

  embedded_manifests = true
  path               = "clusters/uni-dev"
}