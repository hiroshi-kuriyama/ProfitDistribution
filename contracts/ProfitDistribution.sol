// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProfitDistributionContract {
    address payable public addressA;
    address payable public addressB;

    constructor(address payable _addressA, address payable _addressB) {
        addressA = _addressA;
        addressB = _addressB;
    }

    function distributeFunds() external payable {
        uint256 amountToAddressA = (msg.value * 30) / 100;
        uint256 amountToAddressB = msg.value - amountToAddressA;

        addressA.transfer(amountToAddressA);
        addressB.transfer(amountToAddressB);
    }

    function setAddressB(address payable _addressB) external {
        addressB = _addressB;
    }
}