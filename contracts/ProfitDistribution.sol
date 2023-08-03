// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// Importing OpenZeppelin's ERC20 interface version 3.4.2
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.2/contracts/token/ERC20/IERC20.sol";

contract ProfitDistributor {

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

contract TokenDistributor {

    struct Share {
        address payable destinationAddress;
        uint256 percentage;
    }

    Share[] public shares;
    IERC20 public token;

    constructor(address payable[] memory _destinationAddresses, uint256[] memory _percentages, IERC20 _token) {
        require(_destinationAddresses.length == _percentages.length, "Invalid input. Length of _destinationAddresses and _percentages are not same.");

        token = _token;

        for (uint256 i = 0; i < _destinationAddresses.length; i++) {
            shares.push(Share(_destinationAddresses[i], _percentages[i]));
        }
    }

    function distributeTokens(uint256 amount) public {
        require(amount > 0, "No tokens to distribute");

        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            totalPercentage += shares[i].percentage;
        }
        for (uint256 i = 0; i < shares.length; i++) {
            require(token.transferFrom(msg.sender, shares[i].destinationAddress, amount * shares[i].percentage / totalPercentage), "Transfer in loop failed");
        }
    }

    function getShares() public view returns (address[] memory, uint256[] memory) {
        address[] memory destinationAddresses = new address[](shares.length);
        uint256[] memory percentages = new uint256[](shares.length);

        for (uint i = 0; i < shares.length; i++) {
            destinationAddresses[i] = shares[i].destinationAddress;
            percentages[i] = shares[i].percentage;
        }

        return (destinationAddresses, percentages);
    }
}




contract ContractDeployer {
    struct DeployedContract {
        address profitDistributor;
        address tokenDistributor;
    }

    DeployedContract[] public deployedContracts;
    address payable treasuryAddress;
    IERC20 public token;

    event ContractDeployed(address profitDistributor, address tokenDistributor); 

    constructor(address payable _treasuryAddress, IERC20 _token) {
        treasuryAddress = _treasuryAddress;
        token = _token;
    }

    function deployDistributors(address payable[] memory _destinationAddresses, uint256[] memory _percentages) public {
        ProfitDistributor pd = new ProfitDistributor(treasuryAddress, _destinationAddresses, _percentages);
        TokenDistributor td = new TokenDistributor(_destinationAddresses, _percentages, token);
        deployedContracts.push(DeployedContract(address(pd), address(td)));
        emit ContractDeployed(address(pd), address(td));
    }

    function getDeployedContracts() public view returns (address[] memory, address[] memory) {
        address[] memory profitDistributors = new address[](deployedContracts.length);
        address[] memory tokenDistributors = new address[](deployedContracts.length);

        for (uint i = 0; i < deployedContracts.length; i++) {
            profitDistributors[i] = deployedContracts[i].profitDistributor;
            tokenDistributors[i] = deployedContracts[i].tokenDistributor;
        }

        return (profitDistributors, tokenDistributors);
    }
}