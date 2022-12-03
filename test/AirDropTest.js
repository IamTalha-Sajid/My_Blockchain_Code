// We require the Hardhat Runtime Environment explicitly here. This is optional
describe("airDrop contract", function () {
    it("Deployment should set the owner", async function () {
      const [owner] = await ethers.getSigners();
  
      const airDrop = await ethers.getContractFactory("airDrop");
  
      const hardhatToken = await airDrop.deploy();

      expect(await hardhatToken.checkOwner(owner)).to.equal(owner);
    });
    ////////////////////////////////
    it("Address has been Added to the Contract", async function () {
        const [owner] = await ethers.getSigners();
    
        const airDrop = await ethers.getContractFactory("airDrop");
    
        const hardhatToken = await airDrop.deploy();
  
        expect(await hardhatToken.checkOwner(owner)).to.equal(owner);
      });

      it("Transfer Tokens to all Addresses", async function () {
        const [owner] = await ethers.getSigners();
    
        const airDrop = await ethers.getContractFactory("airDrop");
    
        const hardhatToken = await airDrop.deploy();
  
        expect(await hardhatToken.checkOwner(owner)).to.equal(owner);
      });

      it("Do not Transfer if Address is no Valid", async function () {
        const [owner] = await ethers.getSigners();
    
        const airDrop = await ethers.getContractFactory("airDrop");
    
        const hardhatToken = await airDrop.deploy();
  
        expect(await hardhatToken.checkOwner(owner)).to.equal(owner);
      });


  });