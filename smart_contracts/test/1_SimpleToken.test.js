const BigNumber = web3.BigNumber;

const ERC20Template = artifacts.require("ERC20Template");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();

contract("SIMPLE ERC20 TOKEN", accounts=> {

	const _totalSupply = 10000000;
	const _decimals = 18;
	const _name = "Test Token";
	const _symbol = "Test";
	const _isMintable = false;
	const _isBurnable = false;

	/**
	* This creates a new instance of a simple ERC20 token for
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

		it("Token has the name 'Test Token'", async function() {
			const name = await this.token.name();
			name.should.equal(_name);
		});

		it("Token has the symbol 'Test'", async function() {
			const symbol = await this.token.symbol();
			symbol.should.equal(_symbol);
		});

		it("Token has 18 decimals", async function() {
			const decimals = await this.token.decimals();
			decimals.should.be.bignumber.equal(_decimals);
		});

		it("Token has a total supply of 10,000,000", async function() {
			const totalSupply = await this.token.totalSupply();
			totalSupply.should.be.bignumber.equal(_totalSupply);
		});

		it("Token has the correct owner", async function() {
			const owner = await this.token.getOwner();
			owner.should.equal(accounts[0]);
		});

		it("Token balance of owner is correct", async function() {
			const ownerBalance = await this.token.balanceOf(accounts[0]);
			ownerBalance.should.be.bignumber.equal(_totalSupply);
		});

		it("Token is not burnable", async function() {
			const burnable = await this.token.isBurnable();
			burnable.should.equal(false);
		});

		it("Token is not mintable", async function() {
			const mintable = await this.token.isMintable();
			mintable.should.equal(false);
		});

		it("Token transfers correctly", async function(){
			//STEP 1 - TRANSFER 100 TOKENS FROM accounts[0] TO accounts[1].
			await this.token.transfer(accounts[1], 200, {from: accounts[0]});
			//STEP 2 - SINCE THE OWNER's BALANCE WAS ORIGINALLY THE TOTAL SUPPLY OF THE
			//TOKEN, THE BALANCE SHOULD NOW BE EQUAL TO THE TOTAL SUPPLY - 200.
			const ownerBalance = await this.token.balanceOf(accounts[0]);
			ownerBalance.should.be.bignumber.equal(10000000 - 200);
			//STEP 3 - CHECK THAT THE BALANCE OF accounts[1] IS NOW 200.
			const toBalance = await this.token.balanceOf(accounts[1]);
			toBalance.should.be.bignumber.equal(200);
		});

		it("Token approval works correctly", async function(){
			//STEP 1 - CHECK THAT THE ALLOWANCE SET BY THE OWNER TO THE SPENDER STARTS AT 0
			const allowanceBeforeApproval = await this.token.allowance(accounts[0], accounts[1]);
			allowanceBeforeApproval.should.be.bignumber.equal(0);
			//STEP 2 - MAKE THE TOKEN OWNER accounts[0] APPROVE THE ADDRESS AT accounts[1] TO 
			//SPEND UP TO 200 TOKENS FROM THE OWNER's BALANCE
			await this.token.approve(accounts[1], 200, {from: accounts[0]});
			//STEP 3 - CHECK THAT THE ALLOWANCE SET BY THE OWNER TO THE SPENDER IS NOW 200
			const allowanceAfterApproval = await this.token.allowance(accounts[0], accounts[1]);
			allowanceAfterApproval.should.be.bignumber.equal(200);
		});

		it("Token transferFrom works correctly", async function(){
			//STEP 1 - MAKE THE TOKEN OWNER accounts[0] APPROVE THE SPENDER accounts[1] TO
			//SPEND UP TO 200 OF THE OWNER's TOKENS. 
			await this.token.approve(accounts[1], 200, {from: accounts[0]});
			//STEP 2 - MAKE THE SPENDER SEND 100 OF THE OWNERS TOKENS TO accounts[1]
			await this.token.transferFrom(accounts[0], accounts[2], 100, {from: accounts[1]});
			//STEP 3 - CHECK THAT THE OWNERS BALANCE IS NOW 100 LESS THAN THE ORIGINAL BALANCE. 
			const newBalanceOfOwner = await this.token.balanceOf(accounts[0]);
			newBalanceOfOwner.should.be.bignumber.equal(10000000 - 100);
			//STEP 5 - GET THE BALANCE OF THE RECIPIENT accounts[1] AND CHECK THAT IT IS NOW 100.
			const newBalanceOfRecipient = await this.token.balanceOf(accounts[2]);
			newBalanceOfRecipient.should.be.bignumber.equal(100);
			//STEP 6 - CHECK THAT THE SPENDER's ALLOWANCE IS NOW 100 LESS THAN THE ORIGINAL ALLOWANCE
			//BEFORE INOKING THE FUNCTION
			const newAllowanceOfSpender = await this.token.allowance(accounts[0], accounts[1]);
			newAllowanceOfSpender.should.be.bignumber.equal(100);
		});
	})
})