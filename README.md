# ProfitDistribution
![solidity badge](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)  
Code for a smart contract to distribute profit to the DAO members.

# 概要
AiberryDAOのトークンエコノミーを成立させるためのスマートコントラクトを作成しています。収益を自動的に分配するスマートコントラクトです。[コントラクトのソースコードはこちら(ProfitDistribution.sol)。](/contracts/ProfitDistribution.sol)

## ソースコードの説明
- ProfitDistributor
  - 入金されたネイティブトークン（EtherやMATICなど）の30%をトレジャリーに送金すると同時に、残りの70%を任意の数のアドレス宛に任意の割合で分配します。入金を検知すると自動的に分配を執行します。
- TokenDistributor
  - ERC-20トークンをProfitDistributorと同じアドレス（トレジャリーを除く）に分配します。
  - ERC-20はトークンの入金をトリガーにした処理は実装できないので、TokenDistributorへのトークン送金とTokenDistributorからのトークン分配の2手間かかります。
- ContractDeployer
  - 親スマコンです。子スマコン(ProfitDistributorとTokenDistributor)をデプロイするスマコンなので親スマコンと呼んでいます。
  - 親スマコンのデプロイ時にトレジャリーアドレスとトークンアドレスを設定します。つまりこの2つのアドレスはそれ以降の変更は不可能です。
  - 任意の分配先アドレス、任意の分配比率を設定して子スマコンをデプロイすると、ProfitDistributorとTokenDistributorのコントラクトアドレスが新しく発行されます。 

## 使い方
1. Aragonのproposal機能を使ってContractDeployerのdeployDistributors()関数に分配先アドレス等を設定してDAO内での投票にかけます。
2. DAOトークン保有者は分配先アドレスやその比率を確認し、問題ないと判断すればそれぞれがYESの投票をします。
3. 投票によってproposalが可決されれば、deployDistributors()関数とTokenDistributor()関数が実行され、ProfitDistributorとTokenDistributorのコントラクトがデプロイされます。
4. Aiberry㈱が収益をネイティブトークン（EtherやMATCI）でProfitDistributorのコントラクト宛に送金します。すると1での設定通りに自動的にネイティブトークンを分配します。
5. AiberryDAOがTokenDistributorのコントラクト宛にERC-20（今回はAIB）を送金もしくはミントするというproposalを投票にかけます。
6. 投票によってproposalが可決されれば、ERC-20がTokenDistributorのコントラクト宛に送金されます。
7. TokenDistributorのdistributeTokens()関数を実行すると1での設定通りに自動的にERC20トークンを分配されます。（distributeTokens()は投票を経ずに誰でも実行可能）

## テストネットでの動作確認
PolygonのテストネットであるMumbaiにデプロイしたコントラクトは[0x8e1a72F9F30F4902494e4709156A7107b6841d42](https://mumbai.polygonscan.com/address/00x8e1a72F9F30F4902494e4709156A7107b6841d42)です。

これまでに発行した子スマコンは
- [こちらのページ](https://mumbai.polygonscan.com/address/0x8e1a72F9F30F4902494e4709156A7107b6841d42#readContract#F2)で確認することができます。

## Aragonのproposalでの設定の仕方

### 初回はContractDeployerのコントラクトアドレスへの紐づけが必要

https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/4dcc9cb2-8370-4798-9806-a84a5ef387e8

### 「使い方」の1の実施方法
> ContractDeployerのdeployDistributors()関数に分配先アドレス等を設定してDAO内での投票にかけます。


https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/5b079272-01cd-4329-9d7b-6427fb17ac20

### 「使い方」の3の結果の確認方法
ProfitDistributorとTokenDistributorのコントラクトアドレスを確認できます。


https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/5aa1cd7c-32db-416a-8778-ad13cff3196a

https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/edfdc954-a244-4b15-9a1d-6937f6752eab


https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/7a4adf85-1c55-479a-87fa-3b25bb781982

デプロイされた子スマコンに対して送金すると正しく分配されていることがわかる。
例: [0xebeEAE5f7e8bf9C31c86Ecfe5d8312Bf72636C55](https://mumbai.polygonscan.com/tx/0x4cc726240863194d33a39017a80c6340c16c0e2aefd4d6e0553abf4bf670a5e3)



# 今後の課題
## セキュリティ
本格的な運用・実用を始める前に脆弱性がないかの詳細な検証が必要です。

## ガス代の最適化
コントラクトの実行時に消費されるGASの最適化は行っておりません。本格的な運用・実用を始める前に対応することが望まれます。
