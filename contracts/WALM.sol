// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract WALM is ERC20, IERC1155Receiver{

    event  Withdrawal(address indexed src, uint wad, uint idOfALM);

    address public alm;
    uint256 public idOfALM;

    constructor(string memory _name, string memory _symbol, address _ALM, uint _id) public ERC20(_name, _symbol) {
        alm = _ALM;
        idOfALM = _id;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function mint(address operator, uint256 amount) public virtual {
        _mint(operator, amount);
    }

    function burn(address operator, uint256 amount) public virtual {
        _burn(operator, amount);
    }

    function withdraw(uint amountALM) public {
        require(
            balanceOf(msg.sender) >= amountALM,
            "WALM: Insufficeint withdrawal"
        );
        burn(msg.sender, amountALM);
        //Transfer 1155
        IERC1155(alm).safeTransferFrom(address(this), msg.sender, idOfALM, amountALM, " ");
        emit Withdrawal(msg.sender, amountALM, idOfALM);
    }

    //Fallback functions that allows contract to accept incoming 1155
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    external
    override
    returns(bytes4)
    {   
        // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
        mint(operator, value);
        return 0xf23a6e61;
    }
        
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
    external
    override
    returns(bytes4)
    {
        // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
        return 0xbc197c81;
    }
        
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return  interfaceId == 0x01ffc9a7 || interfaceId == 0x4e2312e0;
    }

}