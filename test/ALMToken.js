const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ALMToken Contract ", function () {
    
    let ALMContract;
    let almContract;
    let USDCContract;
    let usdcContract;
    let Presale;
    let presale;
    let admin;
    let addr1;
    let addrs;

    beforeEach(async function () {
       
        ALMContract = await ethers.getContractFactory("ALM");
        Presale = await ethers.getContractFactory("Presale");
        USDCContract = await ethers.getContractFactory("DummyUSDC");

        usdcContract = await USDCContract.deploy();

        [admin, addr1, ...addrs] = await ethers.getSigners();

        almContract = await ALMContract.deploy();

        presale = await Presale.deploy(usdcContract.address, almContract.address, 500, 9500);

        await almContract.setPreSaleContractAddress(presale.address);

    });

    describe("Admin Permission", function () {
       
        it("Should provide permission to deployer as the admin", async function () {
            expect(await almContract.hasRole(almContract.DEFAULT_ADMIN_ROLE(), admin.address)).to.be.true;
        });
        
        it("Should not provide admin permission other than deployer", async function () {
            expect(await almContract.hasRole(almContract.DEFAULT_ADMIN_ROLE(), addr1.address)).to.be.false;
        });
    });

    describe("Create Album ", function () {
        
        it("Should create album and deploy album ERC20 token", async function () {

            const albumCount = 1;
                
            await almContract.connect(addr1).createAlbum(addr1.address, 1000, 11, "AlbumName", "ALM");
            
            expect(await almContract.getcurrentNFTCount()).to.equal(albumCount);
            
            const albumERC20Address = await almContract.getAlbumERC20Token(albumCount);
            const albumExtraInfo = await almContract.getAlbumExtraInfo(albumCount);

            expect(albumExtraInfo.artist).to.equal(addr1.address);
            expect(albumExtraInfo.ercTokenAddress).to.equal(albumERC20Address);
            
        });

    });

    describe("Create Ablum & Presale", function () {
    
        it("Should create album and initilize presale", async function () {
            
            const albumCount = 1;

            await almContract.connect(addr1).createAlbumAndInitializePresale(addr1.address, 1000, 11, "AlbumName2", "ALM2", 10, 99999999999);

            expect(await almContract.getcurrentNFTCount()).to.equal(albumCount);
            
            const albumERC20Address = await almContract.getAlbumERC20Token(albumCount);
            const albumExtraInfo = await almContract.getAlbumExtraInfo(albumCount);

            expect(albumExtraInfo.artist).to.equal(addr1.address);
            expect(albumExtraInfo.ercTokenAddress).to.equal(albumERC20Address);
            
        });
        
    });

});