const { expect } = require("chai");

describe("MyToken contract", function () {
  it("Should set the Destination Wallet Address to the given address", async function () {

    const productManagement = await ethers.getContractFactory("productManagement");

    const hardhatToken = await productManagement.deploy();

    const ownerBalance = await hardhatToken.setDestinationWallet("0x0000000000000000000000000000000000000000");
    expect(await hardhatToken.getDestinationWallet()).to.equal("0x0000000000000000000000000000000000000000");
  });

  it("Should set the USDT Token Wallet Address which will stored", async function () {

    const productManagement = await ethers.getContractFactory("productManagement");

    const hardhatToken = await productManagement.deploy();

    const ownerBalance = await hardhatToken.setUSDTAddress("0x0000000000000000000000000000000000000000");
    expect(await hardhatToken.getUSDTAddress()).to.equal("0x0000000000000000000000000000000000000000");
  });

  it("Should Add Product and it should Exist", async function () {

    const productManagement = await ethers.getContractFactory("productManagement");

    const hardhatToken = await productManagement.deploy();

    const ownerBalance = await hardhatToken.addProduct("1", "Car", "30", "1");
    expect(await hardhatToken.checkProduct(1)).to.equal(true);
  });

});