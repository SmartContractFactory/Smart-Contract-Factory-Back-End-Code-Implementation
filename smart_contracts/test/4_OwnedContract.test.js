const BigNumber = web3.BigNumber;
const truffleAssert = require('truffle-assertions');
const OwnedContract = artifacts.require("Owned");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();

contract("OWNED", accounts=> {

	/**
	* This creates a new instance of an Owned contract
	* every unit test.
	**/
	beforeEach(async function() {
		this.ownershipContract = await OwnedContract.new();
	});

	describe("UNIT TESTS", function() {

		it("Ownership assigned successfully", async function() {
			//STEP 1 - ASSIGN THE OWNER TO BE accounts[0]
			await this.ownershipContract.assignOwner(accounts[0], {from: accounts[0]});
			//STEP 2 - CHECK THAT THE OWNER IS accounts[0]
			const owner = await this.ownershipContract.getOwner();
			owner.should.equal(accounts[0]);
		});

		it("Ownership transferred successfully", async function() {
			//STEP 1 - ASSIGN THE OWNER TO BE accounts[0]
			await this.ownershipContract.assignOwner(accounts[0], {from: accounts[0]});
			//STEP 2 - TRANSFER OWNERSHIP TO accounts[1]
			await this.ownershipContract.transferOwnership(accounts[1], {from: accounts[0]});
			//STEP 3 - CHECK THAT THE OWNER IS NOW accounts[1]
			const owner = await this.ownershipContract.getOwner();
			owner.should.equal(accounts[1]);
		})

		it("onlyOwner modifier works", async function(){
			//STEP 1 - ASSIGN THE OWNER TO BE accounts[0]
			await this.ownershipContract.assignOwner(accounts[0], {from: accounts[0]});
			//STEP 2 - TRY TO TRNASFER OWNERSHIP FROM AN ACCOUNT WHICH IS NOT THE OWNER
			await truffleAssert.reverts(this.ownershipContract.transferOwnership(accounts[1], {from:accounts[1]}));
			//STEP 3 - CHECK THAT THE OWNER IS STILL THE SAME OWNER
			const owner = await this.ownershipContract.getOwner();
			owner.should.equal(accounts[0]);
		});
	})
})