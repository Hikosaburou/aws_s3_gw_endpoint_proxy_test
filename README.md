# aws_s3_gw_endpoint_proxy_test
S3 GWエンドポイント用のプロキシサーバー構築実験

## できるもの
AWSアカウント上に以下を作成する。

- VPC, IGW, パブリックサブネット, ルートテーブル x 2
    - VPC Peeringで接続する。
    - 1つのVPC (Endpoint VPCとする) に S3 GW Endpointを設定する。
    - もう片方のVPC (Client VPC) は特に設定無し。
- EC2インスタンス x 2
    - Endpoint VPC, Client VPCに1台ずつ配置する。
    - Amazon Linux 2の最新版を利用
    - Endpoint VPCのEC2にはSquidをインストールして初期設定で起動する。
    - Client VPCのEC2にはEndpoint VPCのEC2を向くようにプロキシサーバー設定を投入する
        - https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-configure-proxy.html
- S3バケット
    - Gateway VPC Endpoint からの PutObject 以外を拒否するバケットポリシーを記述する。

## 準備

### SSHキーペアの作成

EC2インスタンスにアクセスするためのキーペアを作成する

```
$ ssh-keygen -t rsa -b 4096
```

コンソールでEnterし続けると `~/.ssh/id_rsa`, `~/.ssh/id_rsa.pub` が作成されるので適宜リネームする

```
$ mkdir -p ~/.ssh/keys
$ mv ~/.ssh/id_rsa ~/.ssh/keys/test
$ mv ~/.ssh/id_rsa.pub ~/.ssh/keys/test.pub
```

### クレデンシャル情報を設定

環境変数を設定する。(`AWS_PROFILE` 設定を推奨)

```
### アクセスキーを直接指定する場合 
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx

### 名前付きプロファイルを指定する場合
export AWS_PROFILE="my-profile"

### 名前付きプロファイルでIAMロールを利用する場合、以下を追加する
export AWS_SDK_LOAD_CONFIG=1
```

### terraform.tfvars の作成

```
public_key_path = "/Users/hoge/.ssh/keys/test.pub"
my_ip           = "x.x.x.x/32"
bucket_name     = "test-bucket-name-12345678"
```

各項目に以下要領で値を入れる

| 項目 | 内容 |
|  ------ | ------ |
|  public_key_path | 公開鍵ファイルのパス |
|  my_ip | SSHの接続元IP |
|  bucket_name | S3バケット名 |

## デプロイ

以下コマンドで構成を確認する。

```
$ terraform plan
```

以下コマンドで構成をAWS環境にデプロイする。

```
$ terraform apply
```

- EC2インスタンスにSSH接続

```
### @ 以降に terraform apply で出力されたPublic IPを入れる
$ ssh -i ~/.ssh/keys/test ec2-user@x.x.x.x
```