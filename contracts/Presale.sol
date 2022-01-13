// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ALMToken.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract Presale is IERC1155Receiver{
    using SafeMath for uint256;
    
    event InitialOfferingCreated(uint256 tokenID, uint256 totalTokenOfferingAmount, uint256 pricePerTokenInUSDC, uint256 offeringStartTime, uint256 offeringEndTime);
    event InitalOfferingCancelled(uint256 tokenID, uint256 remainingTokenOfferingAmount, uint256 pricePerTokenInUSDC, uint256 offeringCancellationUnixTime);
    event RedeemedRemainingALM(uint256 tokenID, uint256 remainingTokenOfferingAmount, uint256 pricePerTokenInUSDC, uint256 redeemUnixTime);
    event ALMBought(uint256 tokenID, uint256 ALMAmount);

    struct Sale{
        bool onSale;
        uint256 tokenPrice;
        uint256 offeringEndTime;
    }
    
    //tokenID => ALMSales
    mapping(uint256 => Sale) public ALMSales;

    ALM public immutable ALMContract;
    
    address public USDCAddress;
    address public preSaleOwner; 

    // Rates in 10,000 i.e 5% = 500
    uint256 public preSaleCommision;
    uint256 public artistCommision;

    constructor(address _USDCAddress, address _ALMContract, uint256 _preSaleCommision, uint256 _artistCommision) {
        USDCAddress = _USDCAddress;
        ALMContract = ALM(_ALMContract);
        preSaleOwner = msg.sender;
        require(_preSaleCommision + _artistCommision == 10000, "PreSale: Sum of commisions must be 100%");
        preSaleCommision = _preSaleCommision;
        artistCommision = _artistCommision;
    }

    modifier checkPrice(uint256 _pricePerTokenInUSDC) {
        require(_pricePerTokenInUSDC != 0, "PreSale: VZEPrice should be greater than 1");
        _;
    }
    
    ///@notice Create album tokens offer
    ///@param _tokenID             TokenID to initilize presale offer 
    ///@param _pricePerTokenInUSDC Price of the token for presale
    ///@param _offeringEndUnixTime Ending time of token presale
    function initializeOffering(
        uint256 _tokenID, 
        uint256 _pricePerTokenInUSDC, 
        uint256 _offeringEndUnixTime
    ) external checkPrice(_pricePerTokenInUSDC) {
            
        uint256 currentTime = block.timestamp;
        ALM.AlbumExtraInfo memory albumInfo = ALMContract.getAlbumExtraInfo(_tokenID);

        require(
            currentTime < _offeringEndUnixTime,
            "PreSale: OfferingEndUnixTime cannot be a time of the past i.e _offeringEndUnixTime < currentTime"
            );
        
        require(
            albumInfo.artist == msg.sender,
            "PreSale: Sender is not artist."
            );
        
        require(
            ALMSales[_tokenID].tokenPrice == 0,
            "PreSale: Offering for this tokenID has already been created."
            );


        ALMSales[_tokenID] = Sale({
            onSale: true,
            tokenPrice: _pricePerTokenInUSDC,
            offeringEndTime:_offeringEndUnixTime
        });
        
        emit InitialOfferingCreated(_tokenID, albumInfo.totalCap, _pricePerTokenInUSDC, currentTime, _offeringEndUnixTime);
    }

    ///@notice Cancel the Album token sale Offer
    ///@param _tokenID TokenID to cancel offer 
    function cancelOffering(uint256 _tokenID) external {
        
        Sale storage sale = ALMSales[_tokenID];
        uint256 currentTime = block.timestamp;
        ALM.AlbumExtraInfo memory albumInfo = ALMContract.getAlbumExtraInfo(_tokenID);    

        require(
            currentTime < sale.offeringEndTime,
            "PreSale: Offering already ended, cannot cancel closed offering"
        );
            
        require(
            sale.onSale == true,
            "PreSale: Offering already cancelled"
        );

        require(
            albumInfo.artist == msg.sender,
            "PreSale: Sender is not artist."
        );
    
        sale.onSale = false;
        
        uint256 remainingALM = ALMContract.balanceOf(address(this), _tokenID);
        ALMContract.safeTransferFrom(address(this), msg.sender, _tokenID, remainingALM, " ");

        emit InitalOfferingCancelled(_tokenID, remainingALM, sale.tokenPrice, currentTime);
    }

    ///@notice Redeem remaining ALM after presale ended
    ///@param _tokenID Token id to cancel offer 
    function redeemRemainingALM(uint256 _tokenID) external {
        
        Sale storage sale = ALMSales[_tokenID];
        uint256 currentTime = block.timestamp;
        ALM.AlbumExtraInfo memory albumInfo = ALMContract.getAlbumExtraInfo(_tokenID);    

        require(
            currentTime > sale.offeringEndTime,
            "PreSale: Offering not yet ended"
        );
            
        require(
            albumInfo.artist == msg.sender,
            "PreSale: Sender is not artist."
        );
    
        sale.onSale = false;
        
        uint256 remainingALM = ALMContract.balanceOf(address(this), _tokenID);
        ALMContract.safeTransferFrom(address(this), msg.sender, _tokenID, remainingALM, " ");

        emit RedeemedRemainingALM(_tokenID, remainingALM, sale.tokenPrice, currentTime);
        
    }

    ///@notice Create album tokens offer instantly after minintg the nft
    ///@param _tokenID             Token id to initilize presale offer 
    ///@param _pricePerTokenInUSDC Price of the token for presale
    ///@param _offeringEndUnixTime Ending time of token presale
    function instantInitializeOffering(
        uint256 _tokenID, 
        uint256 _pricePerTokenInUSDC, 
        uint256 _offeringEndUnixTime,
        uint256 _tokenTotalCap
    ) public checkPrice(_pricePerTokenInUSDC) returns(bool){

        uint256 currentTime = block.timestamp;

        require(
            msg.sender == address(ALMContract),
            "PreSale: Only ALM contract can call this function"
        );

        require(
            currentTime < _offeringEndUnixTime,
            "PreSale: OfferingEndUnixTime cannot be a time of the past i.e _offeringEndUnixTime < currentTime"
        );

        require(
            ALMSales[_tokenID].tokenPrice == 0,
            "PreSale: Offering for this tokenID has already been created."
        );

        ALMSales[_tokenID] = Sale({
            onSale: true,
            tokenPrice: _pricePerTokenInUSDC,
            offeringEndTime:_offeringEndUnixTime
        });

        emit InitialOfferingCreated(_tokenID, _tokenTotalCap, _pricePerTokenInUSDC, currentTime, _offeringEndUnixTime);
        return true;
    }

    ///@notice Buy ALM tokens
    ///@param _tokenID               Token id of ALM 
    ///@param _amountOfUSDCToBuyWith Amount of USDC tokens to spend
    function buyALM(uint256 _tokenID, uint256 _amountOfUSDCToBuyWith) external {
        
        Sale storage sale = ALMSales[_tokenID];
        ALM.AlbumExtraInfo memory albumInfo = ALMContract.getAlbumExtraInfo(_tokenID);    
           
        require(
            sale.onSale != false,
            "PreSale: Offering not initialized"
        );     
        
        require(
            block.timestamp < sale.offeringEndTime,
            "PreSale: Offering already ended"
        );
        
        require(
            ALMSales[_tokenID].onSale == true,
            "PreSale: Offering already over/canceled"
        );
        
        require(
            IERC20(USDCAddress).allowance(msg.sender, address(this)) >= _amountOfUSDCToBuyWith,
            "PreSale: PreSale not set as approved address for USDc token"
        );
        
        //Total ALM bought with USDC amount
        uint256 ALMToBuy = _amountOfUSDCToBuyWith.div(sale.tokenPrice);
        
        require(
            ALMToBuy >= 1,
            "PreSale: PreSale insufficient USDC token to buy ALM"
        );        

        //Total USDC used
        uint256 _amountOfUSDCToUse = (_amountOfUSDCToBuyWith.div(sale.tokenPrice)).mul(sale.tokenPrice);
        
        (uint256 _preSaleCommission,uint256 _artistUSDCTokens) = calculateCommissions(_amountOfUSDCToUse); 
       
        ALMContract.safeTransferFrom(address(this), msg.sender, _tokenID, ALMToBuy, " ");

        TransferHelper.safeTransferFrom(USDCAddress, msg.sender, albumInfo.artist, _artistUSDCTokens);
        TransferHelper.safeTransferFrom(USDCAddress, msg.sender, preSaleOwner, _preSaleCommission);

        emit ALMBought(_tokenID, ALMToBuy);
    }
      
    function calculateCommissions(uint256 _amount)
        internal
        view
        returns (
            uint256 _preSaleCommission,
            uint256 _artistUSDCTokens
        )
    {
        _preSaleCommission = cutPer10000(preSaleCommision, _amount); 
        return (
            _preSaleCommission,
            _amount.sub(_preSaleCommission)
        );
    }

    function cutPer10000(uint256 _cut, uint256 _total)
        internal
        pure
        returns (uint256)
    {
        uint256 cutAmount = _total.mul(_cut).div(10000);
        return cutAmount;
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