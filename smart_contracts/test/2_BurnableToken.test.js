const BigNumber = web3.BigNumber;

const ERC20Template = artifacts.require("ERC20Template");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();

contract("BURNABLE ERC20 TOKEN", accounts=> {

	const _totalSupply = 10000000;
	const _decimals = 18;
	const _name = "Test Token";
	const _symbol = "Test";
	const _isMintable = false;
	const _isBurnable = true;

	/**
	* This creates a new instance of a burnable ERC20 token for
	* every unit test.
	**/
	beforeEach(async function() {
		this.token = await ERC20Template.new(
			_totalSupply,
			_decimals,
			_name,
			_symbol,
			_isMintable,
			_isBurnable,
			accounts[0] //This assigns the owner
		);
	});

	describe("UNIT TESTS", function() {

		it("Token burn successfull", async function() {
			//STEP 1 - BURN 200 TOKENS
			await this.token.burnTokens(200, {from: accounts[0]});
			//STEP 2 - CHECK THAT THE OWNER's BALANCE IS NOW EQUAL 
			//TO THE TOTAL SUPPLY - 200.
			const newOwnerBalance = await this.token.balanceOf(accounts[0]);
			newOwnerBalance.should.be.bignumber.equal(10000000 - 200);
		});

		it("Token total supply updated after burning", async function(){
			//STEP 1 - BURN 200 TOKENS
			await this.token.burnTokens(200, {from: accounts[0]});
			//STEP 2 - CHECK THAT THE TOTAL SUPPLY OF THE TOKEN IS NOW
			//200 LESS THAN THE ORIGINAL TOTAL SUPPLY. 
			const totalSupply = await this.token.totalSupply();
			totalSupply.should.be.bignumber.equal(10000000 - 200);
		});
	})
})