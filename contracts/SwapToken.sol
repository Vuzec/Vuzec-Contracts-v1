// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";


contract SwapToken is Ownable, IERC1155Receiver{ 

    address public oldContract;
    address public newContract;

    constructor(address _oldContract, address _newContract){
        oldContract = _oldContract;
        newContract = _newContract;
    }

    ///@dev Swap Old NFT Token for equal amount of New NFT Token of same Id
    ///@param _tokenIds token ids to swap
    ///@param _amounts token amounts to swap 
    function swapToken(uint256[] memory _tokenIds, uint256[] memory _amounts) external{
        IERC1155(oldContract).safeBatchTransferFrom(msg.sender, address(this), _tokenIds, _amounts, '');
        IERC1155(newContract).safeBatchTransferFrom(address(this), msg.sender, _tokenIds, _amounts, '');
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
        if(msg.sender == oldContract)
            IERC1155(newContract).safeTransferFrom(address(this), from, id, value, '');

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
        if(msg.sender == oldContract)
            IERC1155(newContract).safeBatchTransferFrom(address(this), from, ids, values, '');

        return 0xbc197c81;
    }
        
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return  interfaceId == 0x01ffc9a7 || interfaceId == 0x4e2312e0;
    }

}