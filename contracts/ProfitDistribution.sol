contract ForwardEther {

    // 宛先アドレスと分配比率
    struct Share {
        address payable destinationAddress;
        uint256 percentage;
    }
    Share[] public shares;
    address payable treasuryAddress;
    // address payable[] public destinationAddresses;
    // uint256[] public percentages;

    constructor(address payable _treasuryAddress, address payable[] memory _destinationAddresses, uint256[] memory _percentages) {
        treasuryAddress = _treasuryAddress;
        // uint256 totalPercentage = 0;

        // for (uint256 i = 0; i < _percentages.length; i++) {
        //     totalPercentage += _percentages[i];
        // }
        for (uint256 i = 0; i < _destinationAddresses.length; i++) {
            shares.push(Share(_destinationAddresses[i], _percentages[i]));
        }
        // destinationAddresses = _destinationAddresses;
        // percentages = _percentages;
    }

    // コントラクトに送金されたとき、その送金を自動的にdestinationAddressに転送します。
    receive() external payable {
        require(msg.value > 0, "No ethers transferred");
        (bool success, ) = treasuryAddress.call{value: msg.value * 30 / 100}("");
        require(success, "Transfer failed");
        for (uint256 i = 0; i < shares.length; i++) {
            (bool success_i, ) = shares[i].destinationAddress.call{value: msg.value * shares[i].percentage / 100}("");
            require(success_i, "Transfer failed in roop");
        }
    }
}
