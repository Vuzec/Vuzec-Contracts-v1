const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Token contract", function () {
   
    let Token;
    let token;
    let deployer;
    let addr1;
    let addr2;
    let addr3;
    let addrs;

    beforeEach(async function () {
        
        Token = await ethers.getContractFactory("DummyUSDC");
        [deployer, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

        token = await Token.deploy();
    });

    describe("Deployment", function () {
        
        it("Should set the minter to right address", async function () {
            expect(await token.minter()).to.equal(deployer.address);
        });
        
        it("Should assign the total supply of the tokens to the deployer", async function () {
            const deployerBalance = await token.balanceOf(deployer.address);

            expect(await token.totalSupply()).to.equal(deployerBalance);
        });
    });

    describe("Transactions", function () {
        
        it("Should transfer tokens between accounts", async function () {
            await token.transfer(addr1.address, 50);
            const addr1Balance = await token.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(50);
        
            await token.connect(addr1).transfer(addr2.address, 50);
            const addr2Balance = await token.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

    });

    describe("Minting", function () {
       
        it("Should mint tokens and increase total supply", async function () {
            const initialSupply = await token.totalSupply();

            await token.mint(addr3.address, 500);
            
            const finalSupply = await token.totalSupply();
            expect(finalSupply).to.equal(Number(initialSupply) + 500);

            const addr3Balance = await token.balanceOf(addr3.address);
            expect(addr3Balance).to.equal(500);
        });
        
    });

});