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
        for (uint256 i = 0; i < percentages.length; i++) {
            (bool success, ) = destinationAddresses[i].call{value: msg.value * percentages[i] / 100}("");
            require(success, "Transfer failed");
        }
    }
}
