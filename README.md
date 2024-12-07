# ISUCON13をさくらのクラウドでやるためのterraform

Based on: https://github.com/yamamoto-febc/sacloud-terraform-isucon

## 使い方

### envs/*.tfvarsを作って必要な情報を書く

```sh
cp envs/example.tfvars envs/<your_env_name>.tfvars
```

```txt
switch_name      = ""
benchmarker_name = ""
app_name         = ""
```

### variables.tfのpublic_key_pathを書き換える

```terraform
variable "public_key_path" {
  default = "<your_public_key_path>"
}
```

### terraformを実行する

```sh
terraform init
terraform workspace new <your_env_name> # or terraform workspace select <your_env_name>
terraform apply -var-file=envs/<your_env_name>.tfvars
```

ただし、実行には環境変数として`SAKURACLOUD_ACCESS_TOKEN`と`SAKURACLOUD_ACCESS_TOKEN_SECRET`が必要です。

### benchmarkerのIPアドレスを取得する

数分後、SSHでログインできるようになるので、以下のコマンドでbenchmarkerのIPアドレスを取得してください。

```sh
terraform output benchmarker_ip_address
```

### benchmarkerにログインする

```sh
ssh -i <your_private_key_path> ubuntu@<benchmarker_ip_address>
```

### benchmarkerでappのsystemdを破棄する

```sh
scp -i <your_private_key_path> script/disable.sh ubuntu@<benchmarker_ip_address>:~/
```
benchmarkerにloginして、cloud-initプロセスが完了していることを確認したのち、
```sh
./disable.sh
```
を実行する。

これをやらないと、benchmarkerがappを起動してしまうため、パフォーマンスに影響が出る可能性があります。

### terraformを破棄する

```sh
terraform destroy -var-file=envs/<your_env_name>.tfvars
```

「ISUCON」は、LINE株式会社の商標または登録商標です。

## 環境を初期化するために

3台構成にするには、既存のcloud-initが1台向け構成になっているため構築が必要です。

1. [s1] `~/env.sh`を自身のlocal ipにする(これもip aで見れる、192.*のやつ)
    ```txt
    ISUCON13_POWERDNS_SUBDOMAIN_ADDRESS="192.168.0.3"
    ```
2. [s1] `sudo systemctl restart pdns`
3. [s1] `/home/isucon/webapp/pdns/init_zone.sh`
4. [s1] `pdnsutil delete-zone u.isucon.local`
5. [s1] `sudo rm -f /opt/aws-env-isucon-subdomain-address.sh.lock`
6. [s1] `sudo reboot`
