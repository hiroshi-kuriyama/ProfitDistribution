# ProfitDistribution
![solidity badge](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)  
code for a smart contract. Distribute profit in DAO.

# 概要
AiberryDAOのトークンエコノミーを成立させるためのスマートコントラクトを作成しています。収益を自動的に分配するスマートコントラクトです。[コントラクトのソースコードはこちら(ProfitDistribution.sol)。](/contracts/ProfitDistribution.sol)

## ソースコードの説明
- ProfitDistributor
  - 入金されたネイティブトークン（EtherやMATICなど）の30%をトレジャリーに送金すると同時に、残りの70%を任意の数のアドレス宛に任意の割合で分配します。入金を検知すると自動的に分配を執行します。
- TokenDistributor
  - ERC-20トークンをProfitDistributorと同じアドレス（トレジャリーを除く）に分配します。
  - ERC-20はトークンの入金をトリガーにした処理は実装できないので、TokenDistributorへのトークン送金とTokenDistributorからのトークン分配の2手間かかります。
  - 更にはTokenDistributorへのトークン入金者が事前に送金をapproveする必要もあります。（次の実装で解決したい。）
- ContractDeployer
  - 親スマコンです。子スマコン(ProfitDistributorとTokenDistributor)をデプロイするスマコンなので親スマコンと呼んでいます。
  - 親スマコンのデプロイ時にトレジャリーアドレスとトークンアドレスを設定します。つまりこの2つのアドレスはそれ以降の変更は不可能です。
  - 任意の分配先アドレス、任意の分配比率を設定して子スマコンをデプロイすると、ProfitDistributorとTokenDistributorのコントラクトアドレスが新しく発行されます。 

## 使い方
1. Aragonのproposal機能を使ってContractDeployerのdeployDistributors()関数に分配先アドレス等を設定してDAO内での投票にかけます。
2. DAOトークン保有者は分配先アドレスやその比率を確認し、問題ないと判断すればそれぞれがYESの投票をします。
3. 投票によってproposalが可決されれば、deployDistributors()関数とTokenDistributor()関数が実行され、ProfitDistributorとTokenDistributorのコントラクトがデプロイされます。
4. Aiberry㈱が収益をネイティブトークン（EtherやMATCI）でProfitDistributorのコントラクト宛に送金します。すると1での設定通りに自動的にネイティブトークンを分配します。
5. 以下のproposalを投票にかけます。
   a. AiberryDAOがTokenDistributorのコントラクト宛にERC-20（今回はAIB）を送金もしくはミントする
   b. AiberryDAOがaのミント額と同額のapproveを行う（IERC20のapprove関数の実行）
6. 投票によってproposalが可決されれば、ERC-20がTokenDistributorのコントラクト宛に送金されます。
7. TokenDistributorのdistributeTokens()関数を実行すると1での設定通りに自動的にERC20トークンを分配されます。（distributeTokens()は投票を経ずに誰でも実行可能）

# 以下、要修正

## テストネットでの動作確認
PolygonのテストネットであるMumbaiにデプロイしたコントラクトは[0x37FcCE4Ea6b008117f5C0Cf7A47491C7A4b243D5](https://mumbai.polygonscan.com/address/0x37FcCE4Ea6b008117f5C0Cf7A47491C7A4b243D5)です。

これまでに発行した子スマコンは[こちらのページ](https://mumbai.polygonscan.com/address/0x37FcCE4Ea6b008117f5C0Cf7A47491C7A4b243D5#readContract#F2)で確認することができます。

## Aragonのproposalでの設定の仕方


# 今後の課題
## ERC-20の自動分配
Aragonで作成したDAOのトークンはERC-20という種類であることが実装を難しくしています。
子スマコンであるProfitDistributionはネイティブトークンの受け取りをトリガーとして分配が自動実行されるようにプログラムされています（コントラクトがネイティブトークントークンの送金を受けるとreceive()関数が自動実行される）。しかしERC-20トークンにはトークンの受け取りを検知する機能がないため、送金の受け取りをトリガーとすることができません。  
今のところ考えられる対策案は、AIBの分配はスマコン実装ではなく、Aragonにもともとあるmintの機能を使うことです。ただしこれだと2回proposalを実施しなくてはならず、不便さが残ります。。別の対策案を考案中です。

## セキュリティ
本格的な運用・実用を始める前に脆弱性がないかの詳細な検証が必要です。

## ガス代の最適化
コントラクトの実行時に消費されるGASの最適化は行っておりません。本格的な運用・実用を始める前に対応することが望まれます。