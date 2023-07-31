# ProfitDistribution
![solidity badge](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)  
code for a smart contract. Distribute profit in DAO.

# 概要
AiberryDAOのトークンエコノミーを成立させるためのスマートコントラクトを作成しています。収益を自動的に分配するスマートコントラクトです。[コントラクトのソースコードはこちら(ProfitDistribution.sol)。](/contracts/ProfitDistribution.sol)

## ソースコードの説明
- ProfitDistribution（ここでは子スマコンと呼びます）
  - 入金されたネイティブトークン（EtherやMATICなど）の30%をトレジャリーに送金すると同時に、残りの70%を任意の数のアドレス宛に任意の割合で分配します。入金を検知すると自動的に分配を執行します。
- DeployProfitDistribution
  - 親スマコンです。子スマコン(ProfitDistribution)をデプロイするスマコンなので親スマコンと呼んでいます。
  - トレジャリーのアドレス、任意の分配先アドレス、任意の分配比率を設定して子スマコンをデプロイします。 

## 使い方
1. Aragonのproposal機能を使ってDeployProfitDistributionのdeployProfitDistribution()関数に分配先アドレス等を設定してDAO内での投票にかけます。
2. DAOトークン保有者は分配先アドレスやその比率を確認し、問題ないと判断すればそれぞれがYESの投票をします。
3. 投票によってproposalが可決されれば、deployProfitDistribution()関数が実行され、ProfitDistributionがデプロイされます。
4. クライアントもしくはAiberry㈱が収益をネイティブトークンでProfitDistributionのコントラクト宛に送金します。
5. このコントラクトは1での設定通りに自動的にネイティブトークンを分配します。

## テストネットでの動作確認
PolygonのテストネットであるMumbaiにデプロイしたコントラクトは[0x37FcCE4Ea6b008117f5C0Cf7A47491C7A4b243D5](https://mumbai.polygonscan.com/address/0x37FcCE4Ea6b008117f5C0Cf7A47491C7A4b243D5)です。

これまでに発行した子スマコンは[こちらのページ](https://mumbai.polygonscan.com/address/0x37FcCE4Ea6b008117f5C0Cf7A47491C7A4b243D5#readContract#F2)で確認することができます。

## Aragonのproposalでの設定の仕方


https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/edfdc954-a244-4b15-9a1d-6937f6752eab


https://github.com/hiroshi-kuriyama/ProfitDistribution/assets/29877317/7a4adf85-1c55-479a-87fa-3b25bb781982

デプロイされた子スマコンに対して送金すると正しく分配されていることがわかる。
例: [0xebeEAE5f7e8bf9C31c86Ecfe5d8312Bf72636C55](https://mumbai.polygonscan.com/tx/0x4cc726240863194d33a39017a80c6340c16c0e2aefd4d6e0553abf4bf670a5e3)



# 今後の課題
## ERC-20の自動分配
Aragonで作成したDAOのトークンはERC-20という種類であることが実装を難しくしています。
子スマコンであるProfitDistributionはネイティブトークンの受け取りをトリガーとして分配が自動実行されるようにプログラムされています（コントラクトがネイティブトークントークンの送金を受けるとreceive()関数が自動実行される）。しかしERC-20トークンにはトークンの受け取りを検知する機能がないため、送金の受け取りをトリガーとすることができません。  
今のところ考えられる対策案は、AIBの分配はスマコン実装ではなく、Aragonにもともとあるmintの機能を使うことです。ただしこれだと2回proposalを実施しなくてはならず、不便さが残ります。。別の対策案を考案中です。

## セキュリティ
本格的な運用・実用を始める前に脆弱性がないかの詳細な検証が必要です。

## ガス代の最適化
コントラクトの実行時に消費されるGASの最適化は行っておりません。本格的な運用・実用を始める前に対応することが望まれます。
