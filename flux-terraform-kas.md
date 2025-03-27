# flux-cli (Terraform)、KASあり
- Bootstrapで初期構築する以外は全て同様なので割愛とする。
- そもそも、terraformで管理できるリソースが少ないので、メリットはなさそう。OpenTofuも同様
- 初期構築をコード化したいのであればこちらの方法もありかも。
- しかし、Clusterって削除するケースはあまりないと思うので、やっぱり不要かも?

https://registry.terraform.io/providers/fluxcd/flux/latest/docs/resources/bootstrap_git
https://search.opentofu.org/provider/fluxcd/flux/latest