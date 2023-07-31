// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProfitDistributionContract {
    address payable public addressA;  // 分配先のアドレスA
    address payable public addressB;  // 分配先のアドレスB

    constructor(address payable _addressA, address payable _addressB) {
        addressA = _addressA;
        addressB = _addressB;
    }

    receive() external payable {
        distributeFunds();  // コントラクトに送金された際に分配処理を実行する
    }

    function distributeFunds() internal {
        uint256 contractBalance = address(this).balance;  // コントラクトが保持する残高を取得

        // アドレスAとアドレスBへの送金額を計算
        uint256 amountToAddressA = (contractBalance * 30) / 100;
        uint256 amountToAddressB = contractBalance - amountToAddressA;

        // アドレスAとアドレスBに対して分配処理を実行
        addressA.transfer(amountToAddressA);
        addressB.transfer(amountToAddressB);
    }

    function setAddressB(address payable _addressB) external {
        addressB = _addressB;  // アドレスBを変更する関数
    }
}
