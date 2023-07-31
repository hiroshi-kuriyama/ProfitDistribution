// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

// etherを受け取り、送金するコントラクト
contract Pay {
    // payable修飾子のついたaddressはetherを受け取ることができる
    address payable public owner;

    // payable修飾子のついたconstructorはデプロイ時にetherを受け取ることができる
    // msg.senderは関数を呼び出したアドレス（この場合はデプロイしたアドレス）
    constructor() payable {
        owner = payable(msg.sender);
    }

    // Payコントラクトアドレスにetherを送金する関数
    function deposit() payable public {}

    // Payコントラクトアドレスのether残高を返す関数
    // requireでコントラクトデプロイ者のみ実行可能となっている
    function getBalance() public view returns (uint256) {
        require(owner == msg.sender);
        return address(this).balance;
    }

    // Payコントラクトアドレスから_toアドレスに_amount分のetherを送金する関数
    function withdraw(address payable _to, uint _amount) public {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}


// Payコントラクトからetherを受け取るテスト用のコントラクト
contract ReceiveEther {
    // etherを受け取るには"receive() external payable {}"または"fallback() external payable {}"のどちらかが必要

    // receive関数はmsg.dataが空である場合に呼び出される
    receive() external payable {}

    // fallback関数はmsg.dataが空でない場合、存在しない関数が呼び出された場合、receive()が存在しない場合に呼び出される
    fallback() external payable {}

    // ReceiveEtherコントラクトアドレスに入っている残高を返す関数
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract ForwardEther {

    // 宛先アドレス
    address payable[] public destinationAddresses;

    constructor(address payable[] memory _destinationAddresses) {
        destinationAddresses = _destinationAddresses;
    }

    // コントラクトに送金されたとき、その送金を自動的にdestinationAddressに転送します。
    receive() external payable {
        require(msg.value > 0, "No ethers transferred");
        (bool success, ) = destinationAddresses[0].call{value: msg.value * 3 / 10}("");
        require(success, "Transfer failed");
        (bool successB, ) = destinationAddresses[1].call{value: msg.value * 7 / 10}("");
        require(successB, "Transfer failed");
    }
}
