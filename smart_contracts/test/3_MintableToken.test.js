const BigNumber = web3.BigNumber;

const ERC20Template = artifacts.require("ERC20Template");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();

contract("MINTABLE ERC20 TOKEN", accounts=> {

	const _totalSupply = 10000000;
	const _decimals = 18;
	const _name = "Test Token";
	const _symbol = "Test";
	const _isMintable = true;
	const _isBurnable = false;

	/**
	* This creates a new instance of a mintable ERC20 token for
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

		it("Token minting successfull", async function() {
			await this.token.mintTokens(accounts[1], 200, {from: accounts[0]});
			const recipientBalance = await this.token.balanceOf(accounts[1]);
			recipientBalance.should.be.bignumber.equal(200);
		});

		it("Token total supply updated after minting", async function(){
			await this.token.mintTokens(accounts[1], 200, {from: accounts[0]});
			const totalSupply = await this.token.totalSupply();
			totalSupply.should.be.bignumber.equal(10000200);
		});

	})
})