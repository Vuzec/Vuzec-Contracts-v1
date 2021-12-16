// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./WALM.sol";
import "./Presale.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ALM is ERC1155, AccessControl{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    
    event AlbumCreated(address owner, uint256 tokenId, uint256 totalMarketCap, string _albumId, address ercTokenAddress);
    event AlbumTokenMinted(address user, uint256 tokenId, uint256 amount);

    struct AlbumExtraInfo{
        address artist;
        uint256 totalCap;
        address ercTokenAddress;        
    }

    //token id => AlbumExtraInfo
    mapping(uint256 => AlbumExtraInfo) public albumMetadata;
    
    Counters.Counter private _tokenIds;
    Presale public preSaleContract;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    ///@notice checks if caller has admin role
    modifier IsAdmin {
        require(
            this.hasRole(this.DEFAULT_ADMIN_ROLE(), msg.sender),
            "ALM: Caller must have ADMIN role"
        );
        _;
    }

    ///@notice Grants admin role to account
    ///@param _account Adress to be granted role
    function addAdmin(address _account) public IsAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, _account);
    }

    ///@notice Set up the preSaleContract address
    ///@param _preSale Adress of the presale
    function setPreSaleContractAddress(
        address _preSale
    ) external IsAdmin returns (bool){
        preSaleContract = Presale(_preSale);
    }

    ///@dev Create and Deploy ERC20 tokens for an album and deploys it.
    ///@notice It set's the marketplace as the approved address for the tokenTotal supply.
    ///@param _tokenTotalCap Total ERC20 to be minted
    ///@param _name Name for the ERC20 token
    ///@param _symbol Symbol for the ERC20 token
    function deploy(string memory _name, string memory _symbol, uint256 _id) internal returns (address){
        WALM fungibleToken = new WALM(_name, _symbol, address(this), _id);
        return address(fungibleToken);
    }

    ///@notice Creates album ALM token of an album
    ///@param _owner         Address of the artist or album owner
    ///@param _tokenTotalCap Supply of ALM to be minted for presale
    ///@param _albumId       Album id of the album
    function createAlbum(
        address _owner,
        uint256 _tokenTotalCap,
        string memory _albumId,
        string memory _name,
        string memory _symbol
    ) external returns (uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        uint256 totalALM = 1000000;
        address _ercTokenAddress = deploy(_name, _symbol, newItemId);

        albumMetadata[newItemId] = AlbumExtraInfo({
            artist: _owner,
            totalCap: _tokenTotalCap,
            ercTokenAddress: _ercTokenAddress
        });
        address _preSaleContract = address(preSaleContract);
        _mint(_preSaleContract, newItemId, _tokenTotalCap, " ");
        _mint(_owner, newItemId, totalALM.sub(_tokenTotalCap), " ");
        emit AlbumCreated(_owner, newItemId, _tokenTotalCap, _albumId, _ercTokenAddress);
        return newItemId;
    }

    ///@notice Creates album ALM token of an album and initialized presale immediately
    ///@param _owner         Address of the artist or album owner
    ///@param _tokenTotalCap Supply of ALM to be minted for presale
    ///@param _albumId       Album id of the album
    function createAlbumAndInitializePresale(
        address _owner,
        uint256 _tokenTotalCap,
        string memory _albumId,
        string memory _name,
        string memory _symbol,
        uint256 _pricePerTokenInUSDC, 
        uint256 _offeringEndUnixTime
    ) external returns (uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        uint256 totalALM = 1000000;
        address _ercTokenAddress = deploy(_name, _symbol, newItemId);

        albumMetadata[newItemId] = AlbumExtraInfo({
            artist: _owner,
            totalCap: _tokenTotalCap,
            ercTokenAddress: _ercTokenAddress
        });

        address _preSaleContract = address(preSaleContract);
        _mint(_preSaleContract, newItemId, _tokenTotalCap, " ");
        _mint(_owner, newItemId, totalALM.sub(_tokenTotalCap), " ");

        require(preSaleContract.instantInitializeOffering(newItemId, _pricePerTokenInUSDC, _offeringEndUnixTime, _tokenTotalCap),"ALM: Unable to initialize offering");
        emit AlbumCreated(_owner, newItemId, _tokenTotalCap, _albumId, _ercTokenAddress );
        return newItemId;
    }
    
    ///@notice Returns extra info about the album
    ///@param _tokenId  TokenId of the ALM token
    function getAlbumExtraInfo(
        uint256 _tokenId
    ) external view returns (AlbumExtraInfo memory){
        AlbumExtraInfo memory album =  albumMetadata[_tokenId];
        return album;
    }
    
    ///@notice Returns ERC20 of the token
    ///@param _tokenId  TokenId of the ALM token
    function getAlbumERC20Token(uint256 _tokenId) external view returns(address){
        AlbumExtraInfo memory album =  albumMetadata[_tokenId];
        address ad = album.ercTokenAddress;
        return ad;
    }
    
    ///@notice Checks ERC20 balance of the user
    ///@param wal   Wrapped ALM token address
    ///@param user  User address
    function testCheckWALMBalance(address wal, address user) external view returns(uint256){
        uint256 balance = IERC20(wal).balanceOf(user);
        return balance;
    }

    ///@notice Returns number of tokens minted
    function getcurrentNFTCount() external view returns (uint256){
        uint256 currentItemId = _tokenIds.current();
        return currentItemId;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
