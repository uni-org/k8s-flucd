# FluxCd

## 概要
- FluxCdを用いたk8sのGitOpsを実装
- Source Repoは`Gitlab`を使う。
- flux cliのみ使うパターンと、KAS(Kubernetes用のgitlab Agent)を使うパターンなど複数の実装方法がある。それぞれのインストールとデプロイ方法を以下に記載する。

## Index
- [flux-cli (Bootstrap)、KASなし](./flux-cli-no-kas.md)
- [flux-cli (Bootstrap)、KASあり](./flux-cli-kas.md)
- [flux-ope、KASあり](./flux-ope.md)
- [flux-cli (Terraform)、KASなし](./flux-terraform-kas.md)
- [flux-cli (Terraform)、KASあり](./flux-terraform-no-kas.md)

