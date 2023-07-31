// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProfitDistributionContract {
    struct Recipient {
        address payable recipientAddress;
        uint256 distributionPercentage;
    }

    address payable public addressA;  // 分配先のアドレスA
    Recipient[] public recipients;  // 分配先アドレスと割合のリスト

    constructor(address payable _addressA, address payable[] memory _recipientAddresses, uint256[] memory _distributionPercentages) {
        addressA = _addressA;

        // アドレスAをリストに追加 (30%の配分)
        recipients.push(Recipient(addressA, 30));

        // 残りのアドレスと割合をリストに追加 (70%の配分)
        require(_recipientAddresses.length == _distributionPercentages.length, "Invalid input");

        for (uint256 i = 0; i < _recipientAddresses.length; i++) {
            recipients.push(Recipient(_recipientAddresses[i], _distributionPercentages[i]));
        }
    }

    receive() external payable {
        distributeFunds();  // コントラクトに送金された際に分配処理を実行する
    }

    function distributeFunds() internal {
        uint256 contractBalance = address(this).balance;  // コントラクトが保持する残高を取得
        uint256 totalDistributionPercentage = 0;

        // 全体の割合の合計を計算
        for (uint256 i = 0; i < recipients.length; i++) {
            totalDistributionPercentage += recipients[i].distributionPercentage;
        }

        // 各アドレスに対する分配処理を実行
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 amountToRecipient = (contractBalance * recipients[i].distributionPercentage) / totalDistributionPercentage;
            recipients[i].recipientAddress.transfer(amountToRecipient);
        }
    }
}
