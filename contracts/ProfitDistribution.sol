contract ForwardEther {

    // 宛先アドレス
    address payable[] public destinationAddresses;
    uint256[] public percentages;

    constructor(address payable[] memory _destinationAddresses, uint256[] memory _percentages) {
        destinationAddresses = _destinationAddresses;
        percentages = _percentages;
    }

    // コントラクトに送金されたとき、その送金を自動的にdestinationAddressに転送します。
    receive() external payable {
        require(msg.value > 0, "No ethers transferred");
        (bool success, ) = destinationAddresses[0].call{value: msg.value * percentages[0] / 100}("");
        require(success, "Transfer failed");
        (bool successB, ) = destinationAddresses[1].call{value: msg.value * percentages[1] / 100}("");
        require(successB, "Transfer failed");
    }
}
