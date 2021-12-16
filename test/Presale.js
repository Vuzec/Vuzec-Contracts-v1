const { expect } = require("chai");
const { providers, BigNumber } = require("ethers");
const { ethers } = require("hardhat");



describe("Presale Contract", function () {
   
    let ALMContract;
    let almContract;
    let USDCContract;
    let usdcContract;
    let Presale;
    let presale;
    let admin;
    let addr1;
    let addr2;
    let addr3;
    let addrs;

    beforeEach(async function () {

        ALMContract = await ethers.getContractFactory("ALM");
        USDCContract = await ethers.getContractFactory("DummyUSDC");
        Presale = await ethers.getContractFactory("Presale");

        usdcContract = await USDCContract.deploy();
        almContract = await ALMContract.deploy();

        [admin, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

        presale = await Presale.deploy(usdcContract.address, almContract.address, 500, 9500);

        await almContract.setPreSaleContractAddress(presale.address);
    });

    describe("Create Offering", function () {
       
        it("Should initilize the offering", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = 9999999999990;
            

            const tokenCap = 10000; 

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");
            

            expect(await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime)).to.be.
                emit(presale, "InitialOfferingCreated");
        });

        it("Should fail offering for other than artist", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = 9999999999990;

            const tokenCap = 10000; 

            await almContract.connect(addr2).createAlbum(addr2.address, tokenCap, 11, "AlbumName", "ALM");

            await expect(presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime)).to.be.revertedWith("PreSale: Sender is not artist.");
        });

        it("Should fail offering for before past time", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = 99999990;

            const tokenCap = 10000; 

            await almContract.connect(addr2).createAlbum(addr2.address, tokenCap, 11, "AlbumName", "ALM");
            
            await expect(presale.connect(addr2).initializeOffering(tokenId, pricePerToken, offerEndUnixTime)).to.be.revertedWith("PreSale: OfferingEndUnixTime cannot be a time of the past i.e _offeringEndUnixTime < currentTime");
        });
    });
    
    describe("Cancel Offering", function () {
        
        it("Should cancel offering", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = 9999999999990;

            const tokenCap = 10000; 

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");

            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime);

            expect(await presale.connect(addr1).cancelOffering(tokenId)).to.be.
                emit(presale, "InitalOfferingCancelled");

        });


        it("Should fail cancel for sale ended album", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = 9999999999990;

            const tokenCap = 10000; 

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");

            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime);

            sleep(3000).then( async(instance) => {   
                expect(await presale.connect(addr1).cancelOffering(tokenId)).to.be.revertedWith("PreSale: Offering already ended, cannot cancel closed offering");
            });
        });


        it("Should fail cancel for other than artist", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = 9999999999990;

            const tokenCap = 10000; 

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");

            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime);

            await expect(presale.connect(addr2).cancelOffering(tokenId)).to.be.revertedWith("PreSale: Sender is not artist.");
        });


        function sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }
    });

    describe("Reedem ALM", function () {
        it("should redeem reamaing ALM to artist", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = Math.round(new Date() / 1000) + 100;

            const tokenCap = 10000;

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");

            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime);

            sleep(3000).then(async (instance) => {
                expect(await presale.connect(addr1).redeemRemainingALM(tokenId)).to.be.
                    emit(presale, "RedeemedRemainingALM");
            });
        });

        it("should fail redeem remaing ALM to other than artist", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = Math.round(new Date() / 1000) + 100;

            const tokenCap = 10000;

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");

            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime)
            
            sleep(3000).then(async (instance) => {
                await expect(presale.connect(addr3).redeemRemainingALM(tokenId)).to.be.
                    revertedWith("PreSale: Sender is not artist.");
            });
        });

        it("should fail redeem remaing ALM for not ended", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = Math.round(new Date() / 1000) + 100;

            const tokenCap = 10000;

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");

            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime)
            
            await expect(presale.connect(addr3).redeemRemainingALM(tokenId)).to.be.
                revertedWith("PreSale: Offering not yet ended");
            
        });
        
        function sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }
    });


    describe("Buy", function () {
       
        it("should buy token", async function () {
            const tokenId = 1;
            const pricePerToken = 100;
            const offerEndUnixTime = Math.round(new Date() / 1000) + 100;

            const tokenCap = 10000;

            await almContract.connect(addr1).createAlbum(addr1.address, tokenCap, 11, "AlbumName", "ALM");
            
            await presale.connect(addr1).initializeOffering(tokenId, pricePerToken, offerEndUnixTime)
            
            await usdcContract.approve(presale.address, 1050);

            await expect(presale.buyALM(tokenId, 1050)).to.be.
                emit(presale, "ALMBought").withArgs(tokenId, 10);
        });
        
    });
});