contract ForwardEther {

    // 宛先アドレスと分配比率
    struct Share {
        address payable destinationAddress;
        uint256 percentage;
    }
    Share[] public shares;
    address payable treasuryAddress;

    constructor(address payable _treasuryAddress, address payable[] memory _destinationAddresses, uint256[] memory _percentages) {
        // アドレスと分配比率の配列のlengthが異なる場合のエラー処理
        require(_destinationAddresses.length == _percentages.length, "Invalid input. Length of _destinationAddresses and _percentages are not same.");
        
        treasuryAddress = _treasuryAddress;

        for (uint256 i = 0; i < _destinationAddresses.length; i++) {
            shares.push(Share(_destinationAddresses[i], _percentages[i]));
        }

    }

    // コントラクトに送金されたとき、その送金を自動的にdestinationAddressに転送します。
    receive() external payable {
        require(msg.value > 0, "No ethers transferred");

        // トレジャリーには必ず30％を送金
        (bool success, ) = treasuryAddress.call{value: msg.value * 30 / 100}("");
        require(success, "Transfer failed");

        // 残りの70%を分配比率に応じて送金（_percentagesの合計が70でない場合は正規化）
        uint256 totalPercentage = 0;    // 分配比率の正規化のため
        for (uint256 i = 0; i < shares.length; i++) {
            totalPercentage += shares[i].percentage;
        }
        for (uint256 i = 0; i < shares.length; i++) {
            (bool success_i, ) = shares[i].destinationAddress.call{value: msg.value * shares[i].percentage * 70 / totalPercentage / 100}("");
            require(success_i, "Transfer failed in loop");
        }
    }

    function getTreasuryAddress() public view returns (address) {
        return treasuryAddress;
    }

    function getShares() public view returns (address[] memory, uint256[] memory) { // 構造体はそのままreturnできない。
        address[] memory destinationAddresses = new address[](shares.length);
        uint256[] memory percentages = new uint256[](shares.length);

        for (uint i = 0; i < shares.length; i++) {
            destinationAddresses[i] = shares[i].destinationAddress;
            percentages[i] = shares[i].percentage;
        }

        return (destinationAddresses, percentages);
    }
}
