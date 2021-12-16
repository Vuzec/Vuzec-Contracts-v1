// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DummyUSDC is ERC20{
    
    address public minter;
    constructor() public ERC20("Dummy USD Coin", "USDC") {
        _mint(msg.sender, 100000);
        minter = msg.sender;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

     function mint(address to, uint256 amount) public virtual {
         require(msg.sender == minter, "USDC: Non Minter cannot mint token");
        _mint(to, amount);
    }
}
