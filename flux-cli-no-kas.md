# flux-cli (Bootstrap)、KASなし
## 1.1. Install
### 1.1.1. Bootstrap実行用のPTAを追加する。
![Bootstrap実行用のPTAを追加する](./img/install-1.png)

### 1.1.2. fluxcd管理用 Projectを作成する。
![fluxcd管理用 Projectを作成する。](./img/install-2.png)

### 1.1.3. Bootstrap実行
- flux本体となるコンポーネントをdeployするなど、secretや初期構築をやってくれる。

```
% flux bootstrap gitlab \
--hostname=gitlab.com \
--owner=unimin \
--repository=k8s-fluxcd \
--branch=main \
--path=clusters/uni-dev \
--deploy-token-auth
Please enter your GitLab personal access token (PAT): 
► connecting to https://gitlab.com
► cloning branch "main" from Git repository "https://gitlab.com/unimin/k8s-fluxcd.git"
✔ cloned repository
► generating component manifests
✔ generated component manifests
✔ committed component manifests to "main" ("9c6b31a79ef7d2434cbc0dddecc988904ee13784")
► pushing component manifests to "https://gitlab.com/unimin/k8s-fluxcd.git"
► installing components in "flux-system" namespace
（中略…）

% kubectl get pod -n flux-system
NAME                                       READY   STATUS    RESTARTS   AGE
helm-controller-b6767d66-92f7h             1/1     Running   0          37m
kustomize-controller-57c7ff5596-xtzwv      1/1     Running   0          37m
notification-controller-58ffd586f7-kqlmp   1/1     Running   0          37m
source-controller-6ff87cb475-v9tjj         1/1     Running   0          37m

% flux get all
NAME                            REVISION                SUSPENDED       READY   MESSAGE                                           
gitrepository/flux-system       main@sha1:ae1334a1      False           True    stored artifact for revision 'main@sha1:ae1334a1'

NAME                            REVISION                SUSPENDED       READY   MESSAGE                              
kustomization/flux-system       main@sha1:ae1334a1      False           True    Applied revision: main@sha1:ae1334a1
```

<details>

<summary>Bootstrapにて作られるk8sリソース</summary>

```
Deployment/flux-system/helm-controller deleted 
Deployment/flux-system/kustomize-controller deleted 
Deployment/flux-system/notification-controller deleted 
Deployment/flux-system/source-controller deleted 
Service/flux-system/notification-controller deleted 
Service/flux-system/source-controller deleted 
Service/flux-system/webhook-receiver deleted 
NetworkPolicy/flux-system/allow-egress deleted 
NetworkPolicy/flux-system/allow-scraping deleted 
NetworkPolicy/flux-system/allow-webhooks deleted 
ServiceAccount/flux-system/helm-controller deleted 
ServiceAccount/flux-system/kustomize-controller deleted 
ServiceAccount/flux-system/notification-controller deleted 
ServiceAccount/flux-system/source-controller deleted 
ClusterRole/crd-controller-flux-system deleted 
ClusterRole/flux-edit-flux-system deleted 
ClusterRole/flux-view-flux-system deleted 
ClusterRoleBinding/cluster-reconciler-flux-system deleted 
ClusterRoleBinding/crd-controller-flux-system deleted 
toolkit.fluxcd.io finalizers in all namespaces
GitRepository/flux-system/flux-system finalizers deleted 
Kustomization/flux-system/flux-system finalizers deleted 
toolkit.fluxcd.io custom resource definitions
CustomResourceDefinition/alerts.notification.toolkit.fluxcd.io deleted 
CustomResourceDefinition/buckets.source.toolkit.fluxcd.io deleted 
CustomResourceDefinition/gitrepositories.source.toolkit.fluxcd.io deleted 
CustomResourceDefinition/helmcharts.source.toolkit.fluxcd.io deleted 
CustomResourceDefinition/helmreleases.helm.toolkit.fluxcd.io deleted 
CustomResourceDefinition/helmrepositories.source.toolkit.fluxcd.io deleted 
CustomResourceDefinition/kustomizations.kustomize.toolkit.fluxcd.io deleted 
CustomResourceDefinition/ocirepositories.source.toolkit.fluxcd.io deleted 
CustomResourceDefinition/providers.notification.toolkit.fluxcd.io deleted 
CustomResourceDefinition/receivers.notification.toolkit.fluxcd.io deleted 
Namespace/flux-system deleted 
```

</details>

<details>

<summary>Bootstrapにて作られるGitlabリソース</summary>

```
% git pull
warning: redirecting to https://gitlab.com/unimin/k8s-fluxcd.git/
remote: Enumerating objects: 14, done.
remote: Counting objects: 100% (14/14), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 13 (delta 0), reused 4 (delta 0), pack-reused 0 (from 0)
Unpacking objects: 100% (13/13), 59.14 KiB | 8.45 MiB/s, done.
From https://gitlab.com/unimin/k8s-fluxcd
   4d47390..ae1334a  main       -> origin/main
Updating 4d47390..ae1334a
Fast-forward
 clusters/uni-dev/flux-system/gotk-components.yaml | 12584 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 clusters/uni-dev/flux-system/gotk-sync.yaml       |    27 +
 clusters/uni-dev/flux-system/kustomization.yaml   |     5 +
 3 files changed, 12616 insertions(+)
 create mode 100644 clusters/uni-dev/flux-system/gotk-components.yaml
 create mode 100644 clusters/uni-dev/flux-system/gotk-sync.yaml
 create mode 100644 clusters/uni-dev/flux-system/kustomization.yaml


 % cat clusters/uni-dev/flux-system/gotk-sync.yaml 
# This manifest was generated by flux. DO NOT EDIT.
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  secretRef:
    name: flux-system
  url: https://gitlab.com/unimin/k8s-fluxcd.git
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./clusters/uni-dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
% cat gotk-components.yaml | head
---
# This manifest was generated by flux. DO NOT EDIT.
# Flux Version: v2.5.1
# Components: source-controller,kustomize-controller,helm-controller,notification-controller
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app.kubernetes.io/instance: flux-system
    app.kubernetes.io/part-of: flux
```

</details>

## 1.2. Deploy
- kubectl applyにてdeployする方法とflux cliを利用する方法がある。
- kubectl applyを使った場合はfluxコマンドにて関連リソースが表示されない。
- ArgocdにてApplyした場合にhelmコマンドで表示されないのと同様にflux専用のannotationが付けられないため
- fluxで管理できるリソース
```
% flux create
The create sub-commands generate sources and resources.

Usage:
  flux create [command]

Available Commands:
  alert          Create or update a Alert resource
  alert-provider Create or update a Provider resource
  helmrelease    Create or update a HelmRelease resource
  image          Create or update resources dealing with image automation
  kustomization  Create or update a Kustomization resource
  receiver       Create or update a Receiver resource
  secret         Create or update Kubernetes secrets
  source         Create or update sources
  tenant         Create or update a tenant
  （中略…）
```
namespaceは手動で作成しないといけない。

### 1.2.1. Deploy用のProjectを作成する。(fluxcd管理用Projectと同じであっても問題ないはず。)
![Deploy用のProjectを作成する](./img/deploy-1.png)

### 1.2.2. Deploy Tokenを作成する
![Deploy Tokenを作成する](./img/deploy-2.png)

### 1.2.3. k8sリソースを作る_Kustomize
- 階層
```
% tree
.
├── README.md
└── clusters
    └── uni-dev - Cluster階層
        ├── flux-system - Namespace階層
        │   ├── gotk-components.yaml
        │   ├── gotk-sync.yaml
        │   └── kustomization.yaml
        └── test-lee - ※追加
            ├── kustomization.yaml
            ├── test-lee-git-repository.yaml
            ├── test-lee-kustomization.yaml
            ├── test-lee-namespace.yaml
            └── test-lee-secret.yaml

5 directories, 9 files

```

#### 1.2.3.1. kubectl applyにてapplyする場合
- Applicationをdeployするためのfluxリソース
```
% cat test-lee-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-lee
% cat test-lee-git-repository.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: k8s-sample-kustomize
  namespace: test-lee
spec:
  interval: 1m0s
  ref:
    branch: main
  secretRef:
    name: unimin
  url: https://gitlab.com/unimin/k8s-sample-kustomize
% cat test-lee-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: unimin
  namespace: test-lee
data:
  password: Z2xkdC1kdnlKMXZ6YnU5UkdMSlFOOUJBTA==
  username: Z2l0bGFiK2RlcGxveS10b2tlbi11bmltaW4=
type: Opaque
```
usernameとpasswordはbase64でEncodeしたものとなる。本番で使うにはsealedsecretなど別のComponentを使う必要がある。

- Kustomizationリソースを定義（実際にDeployするManifestが格納されているRepoとPathを指定。argocdで言うとApplicationリソース）
```
% cat test-lee-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: sample-kustomize
  namespace: test-lee
spec:
  interval: 1m0s
  path: ./overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: k8s-sample-kustomize
    namespace: test-lee
  targetNamespace: test-lee
```
- kubectl applyを実行
```
% kustomize build . | kubectl apply -f - 
namespace/test-lee created
secret/unimin created
kustomization.kustomize.toolkit.fluxcd.io/sample-kustomize created
gitrepository.source.toolkit.fluxcd.io/k8s-sample-kustomize created
```

- Deploy確認
```
% kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-8khsj   1/1     Running   0          13s
nginx-deployment-647677fc66-wf4b6   1/1     Running   0          13s
```

Deployはされるが、flux cliにて表示されない
```
% flux get all                                             
NAME                            REVISION                SUSPENDED       READY   MESSAGE                                           
gitrepository/flux-system       main@sha1:ae1334a1      False           True    stored artifact for revision 'main@sha1:ae1334a1'

NAME                            REVISION                SUSPENDED       READY   MESSAGE                              
kustomization/flux-system       main@sha1:ae1334a1      False           True    Applied revision: main@sha1:ae1334a1
```

#### 1.2.3.2. flux cliにてapplyする場合
- namespace作成
```
% kubectl create ns test-lee
namespace/test-lee created
```
- secret作成
```
% flux create secret git unimin \
> --url=https://gitlab.com/unimin/k8s-sample-kustomize/overlays/dev \
> --namespace=test-lee \
> --username="gitlab+deploy-token-unimin" \
> --password=gldt-dvyJ1vzbu9RGLJQN9BAL
► git secret 'unimin' created in 'test-lee' namespace

% kubectl get secret -n test-lee
NAME     TYPE     DATA   AGE
unimin   Opaque   2      70s
```

- gitrepo作成
```
% flux create source git k8s-sample-kustomize \
> --url=https://gitlab.com/unimin/k8s-sample-kustomize \
> --branch=main \
> --interval=1m \
> --namespace=test-lee \
> --secret-ref=unimin
✚ generating GitRepository source
► applying GitRepository source
✔ GitRepository source created
◎ waiting for GitRepository source reconciliation
✔ GitRepository source reconciliation completed
✔ fetched revision: main@sha1:e673876a71033f98bbb3a382bbc23c03022fd2c0
```

- kustomization作成
```
% flux create kustomization sample-kustomize \
> --target-namespace=test-lee \
> --source=GitRepository/k8s-sample-kustomize \
> --path=./overlays/dev \
> --prune=true \
> --interval=1m \
> --namespace=test-lee
✚ generating Kustomization
► applying Kustomization
✔ Kustomization created
◎ waiting for Kustomization reconciliation
✔ Kustomization sample-kustomize is ready
✔ applied revision main@sha1:e673876a71033f98bbb3a382bbc23c03022fd2c0
```

- Deploy確認
```
% kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-nbccr   1/1     Running   0          59s
nginx-deployment-647677fc66-rv9pb   1/1     Running   0          59s

% flux get all -A
NAMESPACE       NAME                                    REVISION                SUSPENDED       READY   MESSAGE                                           
flux-system     gitrepository/flux-system               main@sha1:aa7c805a      False           True    stored artifact for revision 'main@sha1:aa7c805a'
test-lee        gitrepository/k8s-sample-kustomize      main@sha1:e673876a      False           True    stored artifact for revision 'main@sha1:e673876a'

NAMESPACE       NAME                            REVISION                SUSPENDED       READY   MESSAGE                              
flux-system     kustomization/flux-system       main@sha1:aa7c805a      False           True    Applied revision: main@sha1:aa7c805a
test-lee        kustomization/sample-kustomize  main@sha1:e673876a      False           True    Applied revision: main@sha1:e673876a
```

fluxの管理配下におくと、fluxコマンドにてkustomizeやgitrepoなどを削除することも可能となるがそこまでメリットはなさそう。
```
% flux delete kustomization sample-kustomize -n test-lee 
Are you sure you want to delete this kustomization: y
% flux get source git -n test-lee
✗ no GitRepository objects found in "test-lee" namespace
```

### 1.2.4. k8sリソースを作る_Helm
#### 1.2.4.1. kubectl applyにてapplyする場合
- Gitlab の Projectを helm repoとして使うためには、Projectの`Package registry`に helm chartをArchive形式にpushしないといけない。
- helm repo用 Projectを作成。（既存のProjectを使っても問題ない。）
![helm repo用 Projectを作成](./img/deploy-helm-1.png)

- Package registry管理とDeploy用のユーザを作成
  - read_repository, read_package_registry, write_package_registry
![helm repo用 Userを作成](./img/deploy-helm-2.png)

- helm chartを作成し、Archiveする
```
% tree sample-helm
sample-helm
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   └── service.yaml
├── values
│   └── uni-dev-values.yaml
└── values.yaml

% cat Chart.yaml 
apiVersion: v2
name: sample-helm
description: A Helm chart for Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "1.16.0"

% cat templates/deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: {{ .Values.deployment.replicas }}
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80

% cat values/uni-dev-values.yaml 
deployment:
  replicas: 2

% cat values.yaml
# Default values file.

deployment:
  replicas: 1

% helm package sample-helm
Successfully packaged chart and saved it to: /Users/systemi/Work/gitlab/k8s-sample-helm/sample-helm-0.1.0.tgz

% ls
README.md               sample-helm             sample-helm-0.1.0.tgz
```
多分valuesは不要なのかも。

- Package Registryにpush
```
% helm repo add --username gitlab+deploy-token-unimin --password xxxx k8s-sample-helm https://gitlab.com/api/v4/projects/68340042/packages/helm/stable
% helm cm-push sample-helm-0.1.0.tgz k8s-sample-helm
% helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "k8s-sample-helm" chart repository
Update Complete. ⎈Happy Helming!⎈
% helm repo list
NAME            URL                                                             
k8s-sample-helm https://gitlab.com/api/v4/projects/68340042/packages/helm/stable
% helm search repo
NAME                            CHART VERSION   APP VERSION     DESCRIPTION                
k8s-sample-helm/sample-helm     0.1.0           1.16.0          A Helm chart for Kubernetes
```
![Package Registryにpush](./img/deploy-helm-3.png)

- namespace作成
```
% kubectl create ns test-lee
namespace/test-lee created
```

- HelmRepositoryへアクセスするDeploy PTAをsecretに登録
```
% cat test-lee-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: unimin
  namespace: test-lee
data:
  password: Z2xkdC1oUG43Ml9CaGd1dzlhNTJ5d3BuLQ==
  username: Z2l0bGFiK2RlcGxveS10b2tlbi11bmltaW4=
type: Opaque

% kubectl apply -f test-lee-secret.yaml 
secret/unimin created
```

- HelmRepository作成
```
% cat test-lee-helm-repository.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: k8s-sample-helm
  namespace: test-lee
spec:
  interval: 1m0s
  secretRef:
    name: unimin
  url: https://gitlab.com/api/v4/projects/68340042/packages/helm/stable

% kubectl apply -f test-lee-helm-repository.yaml
```

- HelmRelease作成
```
% cat test-lee-helm.yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: sample-helm
  namespace: test-lee
spec:
  interval: 1m
  timeout: 5m
  chart:
    spec:
      chart: sample-helm
      version: '0.1.0'
      sourceRef:
        kind: HelmRepository
        name: k8s-sample-helm
      interval: 5m
  releaseName: sample-helm
  install:
    remediation:
      retries: 3
  upgrade:
    remediation:
      retries: 3
  test:
    enable: true

% kubectl apply -f test-lee-helm.yaml
helmrelease.helm.toolkit.fluxcd.io/sample-helm created
```

valuesを指定する方法はInlineとconfigmapを使う方法がある。ここではとりあえずdefault valueを使う。</br>
https://fluxcd.io/flux/components/helm/helmreleases/#values

- Deploy確認
```
% kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-xdgn6   1/1     Running   0          63s

% helm list -n test-lee
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
sample-helm     test-lee        1               2025-03-25 12:13:08.594585117 +0000 UTC deployed        sample-helm-0.1.0       1.16.0    
```

helm commnadでも表示されているので、argocdと違って、helm annotationもつけてくれるみたい。

#### 1.2.4.2. flux cliにてapplyする場合
割愛とする。

## 1.3. Reconcile
- Argocdの場合、Web uiでk8sとgit repoとの差分をチェックし、Syncを行うとReconcileされる。
  - Auto syncのoptionがあって、Git pushと共にk8sに反映させることも可能（完全Gitops）
- Fluxも似たようなことは可能だが、基本的に完全Gitops運用を推奨しているみたい。
  - Kustomizationリソース`spec.interval`が Git Repoとk8s間の同期間隔となる。例えば以下の設定だと`、１分間隔で同期する設定となっている。
```
% cat test-lee-kustomization.yaml 
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: sample-kustomize
  namespace: test-lee
spec:
  interval: 1m0s
  path: ./overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: k8s-sample-kustomize
    namespace: test-lee
  targetNamespace: test-lee
```
- Argocdみたいに diff -> syncを行うための手順をまとめる。

### 1.3.1. Kustomize
#### 1.3.1.1. suspended値で制御する方法。
- 自動Syncを完全に止める方法。Reconcileはfluxコマンドにて行う。
```
% cat test-lee-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: sample-kustomize
  namespace: test-lee
spec:
  suspend: true  -> 追加
  interval: 1m0s
  path: ./overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: k8s-sample-kustomize
    namespace: test-lee
  targetNamespace: test-lee

% kubectl apply -f test-lee-kustomization.yaml
kustomization.kustomize.toolkit.fluxcd.io/sample-kustomize configured

% flux get kustomization -n test-lee
NAME                    REVISION                SUSPENDED       READY   MESSAGE                              
sample-kustomize        main@sha1:bed1337a      True            True    Applied revision: main@sha1:bed1337a
```
-> SUSPENDEDがTrueに変更されていればOK。

- manifest修正
```
% cat deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: test-lee
spec:
  replicas: 2 1->2
```
これをgitlabにpush

- 差分確認
```
% flux diff kustomization sample-kustomize --path ./overlays/dev -n test-lee
✓  Kustomization diffing...
► Deployment/test-lee/nginx-deployment drifted

metadata.generation
  ± value change
    - 2
    + 3

spec.replicas
  ± value change
    - 1
    + 2

⚠️ identified at least one change, exiting with non-zero exit code
```
結局、Local上のpathを指定しないといけないのでkubectl diffと変わらないと思われる。
```
% kustomize build overlays/dev | kubectl diff -f -
diff -u -N /var/folders/x9/3zdz463n2l75zq24qxbm1_4r0000gn/T/LIVE-23686332/apps.v1.Deployment.test-lee.nginx-deployment /var/folders/x9/3zdz463n2l75zq24qxbm1_4r0000gn/T/MERGED-760847638/apps.v1.Deployment.test-lee.nginx-deployment
--- /var/folders/x9/3zdz463n2l75zq24qxbm1_4r0000gn/T/LIVE-23686332/apps.v1.Deployment.test-lee.nginx-deployment 2025-03-26 11:04:20
+++ /var/folders/x9/3zdz463n2l75zq24qxbm1_4r0000gn/T/MERGED-760847638/apps.v1.Deployment.test-lee.nginx-deployment      2025-03-26 11:04:20
@@ -4,7 +4,7 @@
   annotations:
     deployment.kubernetes.io/revision: "1"
   creationTimestamp: "2025-03-26T00:55:13Z"
-  generation: 2
+  generation: 3
   labels:
     kustomize.toolkit.fluxcd.io/name: sample-kustomize
     kustomize.toolkit.fluxcd.io/namespace: test-lee
@@ -14,7 +14,7 @@
   uid: 2a0a4907-26a9-4090-8198-ae39e96b8a5a
 spec:
   progressDeadlineSeconds: 600
-  replicas: 1
+  replicas: 2
   revisionHistoryLimit: 10
   selector:
     matchLabels:
```
- 差分確認後、問題なければreconcileする。
```
% flux reconcile kustomization sample-kustomize -n test-lee
✗ resource is suspended
```
この状態でreconcileするとできないので、suspendedを強制的にfalseに変更してreconcileを実施。
```
% flux resume kustomization sample-kustomize -n test-lee
► resuming kustomization sample-kustomize in test-lee namespace
✔ kustomization resumed
◎ waiting for Kustomization reconciliation
✔ Kustomization sample-kustomize reconciliation completed
✔ applied revision main@sha1:a37106120e11bf8d7d32246a1fffb629863b5c4a

$ kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-hrxgn   1/1     Running   0          80m
nginx-deployment-647677fc66-ndnmj   1/1     Running   0          8s    -> podが追加されている。

% flux get kustomization -n test-lee                       
NAME                    REVISION                SUSPENDED       READY   MESSAGE                              
sample-kustomize        main@sha1:7eb26d51      False           True    Applied revision: main@sha1:7eb26d51

```
suspendがfalseに変わってる。</br>
通常は resumeするとreconcileまでやってくれるが、即時に反映させたい場合などは手動実行を行う。

- Reconcileが終わったら、suspendを元の状態に戻す。
```
% flux suspend kustomization sample-kustomize -n test-lee
► suspending kustomization sample-kustomize in test-lee namespace
✔ kustomization suspended

% flux get kustomization -n test-lee                                        
NAME                    REVISION                SUSPENDED       READY   MESSAGE                              
sample-kustomize        main@sha1:7eb26d51      False           True    Applied revision: main@sha1:7eb26d51
```

#### 1.3.1.2. interval値を30mなどすぐに反映されないように増やして、reconcileで制御する方法。
- Kustomizationリソースを変更しなくても良いので、こちらの方が個人的には良さそうに見える。
- suspend値を削除してintervalを30mに変更する。
- GitRepositoryのintervalはGitRepo上のmanifest変更を検知する間隔。
- Kustomizationのintervalは上記を検知後に実際にreconcileする間隔。
- 細かな設定値が与える影響がよくわからないので、とりあえず30m同値にする
```
% cat test-lee-git-repository.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: k8s-sample-kustomize
  namespace: test-lee
spec:
  interval: 30m
  ref:
    branch: main
  secretRef:
    name: unimin
  url: https://gitlab.com/unimin/k8s-sample-kustomize

% cat test-lee-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: sample-kustomize
  namespace: test-lee
spec:
  interval: 30m
  retryInterval: 2m0s
  path: ./overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: k8s-sample-kustomize
    namespace: test-lee
  targetNamespace: test-lee

% kustomize build . | kubectl apply -f -
namespace/test-lee created
secret/unimin created
kustomization.kustomize.toolkit.fluxcd.io/sample-kustomize created
gitrepository.source.toolkit.fluxcd.io/k8s-sample-kustomize created

% flux get kustomization -n test-lee
NAME                    REVISION                SUSPENDED       READY   MESSAGE                              
sample-kustomize        main@sha1:4a560e4b      False           True    Applied revision: main@sha1:4a560e4b

$ kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-hrxgn   1/1     Running   0          105m
```

- manifest修正
```
% cat overlays/dev/deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: test-lee
spec:
  replicas: 5

$ kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-jq2p8   1/1     Running   0          89s
```

即座にreconcileされない。

- 差分確認
```
% flux diff kustomization sample-kustomize --path ./overlays/dev -n test-lee
✓  Kustomization diffing...
► Deployment/test-lee/nginx-deployment drifted

metadata.generation
  ± value change
    - 1
    + 2

spec.replicas
  ± value change
    - 1
    + 5

⚠️ identified at least one change, exiting with non-zero exit code
```

- reconcile
```
% flux reconcile source git k8s-sample-kustomize -n test-lee                
► annotating GitRepository k8s-sample-kustomize in test-lee namespace
✔ GitRepository annotated
◎ waiting for GitRepository reconciliation
✔ fetched revision main@sha1:3cb226b37a36c4211116c9e591f154768ab2de85

$ kubectl get pod -n test-lee
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-647677fc66-2t2gc   1/1     Running   0          8s
nginx-deployment-647677fc66-8qj22   1/1     Running   0          8s
nginx-deployment-647677fc66-jq2p8   1/1     Running   0          2m37s
nginx-deployment-647677fc66-q7hv2   1/1     Running   0          8s
nginx-deployment-647677fc66-rwhc4   1/1     Running   0          8s
```
即座にreconcileされる。

### 1.3.2. Helm
(Tobe)

## 1.4. Uninstall
### 1.4.1. k8s関連リソースを削除
```
% flux uninstall
Are you sure you want to delete Flux and its custom resource definitions: y
► deleting components in flux-system namespace
✔ Deployment/flux-system/helm-controller deleted 
✔ Deployment/flux-system/kustomize-controller deleted 
✔ Deployment/flux-system/notification-controller deleted 
✔ Deployment/flux-system/source-controller deleted 
✔ Service/flux-system/notification-controller deleted
（中略…）
```

### 1.4.2. Gitlabで関連リソースを手動削除
(Tobe)
