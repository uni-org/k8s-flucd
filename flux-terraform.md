# flux-cli (Terraform)、KASあり
- Bootstrapで初期構築する以外は全て同様なので割愛とする。
- そもそも、terraformで管理できるリソースが少ないので、メリットはなさそう。OpenTofuも同様
- 初期構築をコード化したいのであればこちらの方法もありかも。
- しかし、Clusterって削除するケースはあまりないと思うので、やっぱり不要かも?

https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git
https://search.opentofu.org/provider/fluxcd/flux/latest

## Install
- Bootstrapでfluxを初期構築するどころまでやってくれる。

### Terraform構成
```
% tree terraform 
terraform
├── backend.tf
├── main.tf
└── variables.tf

1 directory, 3 files

% cat backend.tf 
terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.5.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.10"
    }
  }
  backend "s3" {
    bucket = "terraform-bucket-created-by-unimin"
    region = "ap-northeast-1"
    key    = "fluxcd/terraform.tfstate"
  }
  required_version = "~>1.11.1"
}

provider "gitlab" {
  token = var.gitlab_token
}

provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://gitlab.com/unimin/k8s-fluxcd"
    http = {
      username = "unimin"
      password = var.gitlab_token
    }
  }
}

% cat main.tf 
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

% cat variables.tf 
# % export TF_VAR_gitlab_token=XXXX
variable "gitlab_token" {
  description = "The GitLab token to use for authenticating against the GitLab API."
  sensitive   = true
  type        = string
  default     = ""
}
```

### Terraform実行
```
% terraform fmt
% terraform init
% terraform plan -out=tfplan
% terraform apply tfplan
```

### 実行結果
```
$ kubectl get ns
NAME              STATUS   AGE
default           Active   26m
flux-system       Active   43s
kube-flannel      Active   26m
kube-node-lease   Active   26m
kube-public       Active   26m
kube-system       Active   26m

$ kubectl get pod -n flux-system
NAME                                       READY   STATUS    RESTARTS   AGE
helm-controller-b6767d66-9rvlh             1/1     Running   0          44s
kustomize-controller-57c7ff5596-svd7c      1/1     Running   0          44s
notification-controller-58ffd586f7-wvskx   1/1     Running   0          44s
source-controller-6ff87cb475-8fg4n         1/1     Running   0          44s
```
flux-system namespaceに各種controllerが動いている。

```
% tree
.
├── README.md
└── clusters
    └── uni-dev
        └── flux-system
            ├── gotk-components.yaml
            ├── gotk-sync.yaml
            └── kustomization.yaml

4 directories, 4 files
```
flux bootstrapコマンドと同様にgitlab projectにflux componentをインストールするためのmanifest fileが作られる。

