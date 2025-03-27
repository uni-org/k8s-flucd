# flux-ope、KASあり
## 1. 無償版
- https://flux-framework.org/flux-operator/getting_started/index.html
- https://github.com/flux-framework/flux-operator/tree/main

Githubの記録を見るとあんまり、活動していない。そもそも公式Docに書いてある手順でインストールできない。</br>
Versionも0.1.0で止まっているので参考資料も少ないのが現状。</br>
これを採用するのは危なそう。

## 2. 有償版
https://fluxcd.control-plane.io/operator/

- GitlabからもこちらのOperator構成をお勧めしているが、コストかかる。
- 一応できることはかなり多くて、何よりもHub & Spoke構成が可能となるため、Fluxの各種Conponentを一つのクラスタで統合管理することができる。
- Openshiftとの互換性も取れていると書かれている。Openshiftからの提供版もあるみたい。
  - https://github.com/controlplaneio-fluxcd/flux-operator/blob/main/config/terraform/main.tf
  - https://fluxcd.control-plane.io/operator/install/