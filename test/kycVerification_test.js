import { expect } from "chai";
import { ethers } from "hardhat";
import { KYCVerification } from "../contracts/KYCVerification.sol"

describe("KYCVerification", function () {
    let contract: KYCVerification;
  
    beforeEach(async () => {
      const KYCVerification = await ethers.getContractFactory("KYCVerification");
      contract = await KYCVerification.deploy();
    });

    describe("value", () => {
        it("should return True when given parameters are Bank Name and Bank Address", async function () {
          await contract.deployed();
    
          const sum = await contract.addNewBankbyRBI("BAHL", 0x71C7656EC7ab88b098defB751B7401B5f6d8976F);
    
          expect(sum).to.be.not.undefined;
          expect(sum).to.be.not.null;
          expect(sum).to.be.not.NaN;
          expect(sum).to.equal(true);
        });
    });
});