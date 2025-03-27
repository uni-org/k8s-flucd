# FluxCd

## 概要
- FluxCdを用いたk8sのGitOpsを実装
- Source Repoは`Gitlab`を使う。
- flux cliのみ使うパターンと、KAS(Kubernetes用のgitlab Agent)を使うパターンなど複数の実装方法がある。それぞれのインストールとデプロイ方法を以下に記載する。

## Index
- [flux-cli (Bootstrap)、KASなし](./flux-cli-no-kas.md)
- [flux-cli (Bootstrap)、KASあり](./flux-cli-kas.md)
- [flux-ope](./flux-ope.md)
- [flux-terraform](./flux-terraform.md)

## Conclusion

### どの構成パターンが良い？
- コストかけて良いのであれば、flux-ope の hub and spoke構成がKaaSに適している。
  - 各クラスタにflux componentを入れなくて良くなるため、
    - 運用コストの削減
- コストかけずに自動化するのでれば、`flux-cli (Bootstrap)、KASあり`が望ましいと思われる。
  - terraformにて、flux componentをインストールすることも可能だが、全自動化のことを考えると（将来的にはWeb Consoleからパラメータを入力しGUIベースでクラスタを作成する予定）向いてないと思われる。
    - 自動的にterraformコードを作成->git pushする仕組みが必要となるため
  - ただし、KASを導入することによって各クラスタに`gitlab-agent`とのコンポーネントが増えてしまうのが少し懸念。
  - KASを導入せず、gitlabにpushした瞬間、gitlab ci/cd機能にて差分のソースコードのみkubectl applyを行うworkflowを実装すればいけそう。※要確認

### helm vs kustomize?
#### kustomize構成
- 全体図

![kustomize](./img/gitlab-flux-kustomize.drawio.svg)

- ディレクトリ構造(KASあり)
```
clusters --> Space for flux ope
└── uni-dev --> Cluster階層
    ├── flux-system --> Namespace階層
    │   ├── gotk-components.yaml
    │   ├── gotk-sync.yaml
    │   └── kustomization.yaml
    └── fluentd
        ├── fluentd-git-repository.yaml
        ├── fluentd-kustomization.yaml
        ├── fluentd-namespace.yaml
        ├── fluentd-secret.yaml
        ├── kustomization.yaml
        └── ...
systems --> Space for kustomize
└── fluentd
    ├── base
    │   ├── kustomization.yaml   
    │   └── ...
    └── overlays
        ├── cluster_A
        │   ├── kustomization.yaml
        │   └── ...
        ├── cluster_B
        │   ├── kustomization.yaml
        │   └── ...
        └── ...
```
-> KASを使うパターンだとclusters/uni-devに置かないと他のクラスタにdeployしてしまう可能性もあるのでこの構成じゃないとだめ。</br>
-> overlays配下にclusterごとのディレクトリを作成。

- ディレクトリ構造(KASなしでci/cdを利用)
```
clusters --> Space for flux ope
├── uni-dev --> Cluster階層
│   ├── flux-system --> Namespace階層
│   │   ├── gotk-components.yaml
│   │   ├── gotk-sync.yaml
│   │   └── kustomization.yaml
└── flux-common --> 全クラスターの全コンポーネントをファイル名として分ける。
    ├── {cluster_name}-{component_name}.yaml
    └── ...
systems --> Space for kustomize
└── fluentd
    ├── base
    │   ├── kustomization.yaml   
    │   └── ...
    └── overlays
        ├── cluster_A
        │   ├── kustomization.yaml
        │   └── ...
        ├── cluster_B
        │   ├── kustomization.yaml
        │   └── ...
        └── ...
```
-> KASを使わないパターンだと各種コンポーネントのgitrepoとkustomization定義を一つのスペースに一つのファイルとして定義すれば良いのでディレクトリ構成は簡潔になる。</br>
-> ci/cdの仕様にとると思うが、Github actionsだとできるはず。

#### helmの構成
- 全体図

![helm](./img/gitlab-flux-helm.drawio.svg)

- ディレクトリ構成(KASあり)
```
clusters --> Space for flux ope
└── uni-dev --> Cluster階層
    ├── flux-system --> Namespace階層
    │   ├── gotk-components.yaml
    │   ├── gotk-sync.yaml
    │   └── kustomization.yaml
    └── fluentd
        ├── fluentd-helm-repository.yaml
        ├── fluentd-helm-release.yaml
        ├── fluentd-helm-chart.yaml
        ├── fluentd-config.yaml --> chartのvalueをここで記載。
        └── ...
systems --> Space for helm chart
└── component_A --> 自前で作成した管理系コンポーネントがあれば
    ├── Chart.yaml
    ├── README.md
    ├── sample-helm-0.1.0.tgz
    ├── templates
    │   ├── deployment.yaml
    │   └── service.yaml
    └── values.yaml
```

- ディレクトリ構成(KASなし)
```
clusters --> Space for flux ope
├── uni-dev --> Cluster階層
│   ├── flux-system --> Namespace階層
│   │   ├── gotk-components.yaml
│   │   ├── gotk-sync.yaml
│   │   └── kustomization.yaml
└── flux-common --> 全クラスターの全コンポーネントをファイル名として分ける。
    ├── {cluster_name}-{component_name}.yaml
    └── ...
systems --> Space for helm chart
└── component_A --> 自前で作成した管理系コンポーネントがあれば
    ├── Chart.yaml
    ├── README.md
    ├── sample-helm-0.1.0.tgz
    ├── templates
    │   ├── deployment.yaml
    │   └── service.yaml
    └── values.yaml
```

-> 外部のhelm chartを参照するだけなら、Space for helm chartは使わなくて良い。
