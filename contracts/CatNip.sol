// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract CatnipToken is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    address public charityWallet;  // Address for collecting charity donations
    uint256 public charityFee;     // Charity fee percentage (in basis points, i.e., parts per ten thousand)
    uint256 public feeDivisor;     // Divisor to calculate fee (e.g., 10,000 for basis points)

    function initialize(address _charityWallet, uint256 _initialSupply, uint256 _charityFee) public initializer {
        __ERC20_init("Catnip", "CATNIP");
       address owner = msg.sender;
       __Ownable_init(owner);

        charityWallet = _charityWallet;
        charityFee = _charityFee;
        feeDivisor = 10000;  // Set divisor to 10,000 for basis point calculation (1% = 100 basis points)

        _mint(msg.sender, _initialSupply * (10 ** decimals()));
    }

    function setCharityWallet(address _charityWallet) external onlyOwner {
        require(_charityWallet != address(0), "Invalid address");
        charityWallet = _charityWallet;
    }

    function setCharityFee(uint256 _charityFee) external onlyOwner {
        require(_charityFee <= feeDivisor, "Fee too high");
        charityFee = _charityFee;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        // Calculate the charity donation based on the transaction amount
        uint256 feeAmount = (amount * charityFee) / feeDivisor;

        // Deduct the fee from the amount to be transferred
        uint256 amountAfterFee = amount - feeAmount;

        // Transfer the fee to the charity wallet
        super._transfer(sender, charityWallet, feeAmount);

        // Transfer the remaining amount to the recipient
        super._transfer(sender, recipient, amountAfterFee);
    }
}
