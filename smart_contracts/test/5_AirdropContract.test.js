const BigNumber = web3.BigNumber;

const AirdropContract = artifacts.require("AirdropTemplate");
const ERC20Template = artifacts.require("ERC20Template");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();

contract("AIRDROP", accounts=> {

	const _totalSupply = 10000000;
	const _decimals = 18;
	const _name = "Test Token";
	const _symbol = "Test";
	const _isMintable = false;
	const _isBurnable = false;

	/**
	* This creates a new instance of an Airdrop contract
	* for every unit test.
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
		this.airdropContract = await AirdropContract.new(this.token.address, accounts[0]);
	});

	describe("UNIT TESTS", function() {

		it("Airdrop contract has correct token address", async function(){
			const tokenAddress = await this.airdropContract.token();
			tokenAddress.should.equal(this.token.address);
		});

		it("Single value airdrop successful", async function() {
			//STEP 1 - SEND 50000 TOKENS TO THE AIRDROP CONTRACT ADDRESS
			await this.token.transfer(this.airdropContract.address, 50000, {from: accounts[0]});
			//STEP 2 - SEND 10 TOKENS TO ACCOUNTS 1, 2 & 3 FROM ACCOUNT 0.
			await this.airdropContract.singleValueAirdrop(
				[accounts[1],accounts[2],accounts[3]],
				10,
				{from: accounts[0]}
			);
			//STEP 3 - CHECK THAT THE TOKEN BALANCES OF ACCOUNTS 1, 2, & 3 
			//ARE NOW 10 EACH.
			const acc_1_balance = await this.token.balanceOf(accounts[1]);
			acc_1_balance.should.be.bignumber.equal(10);

			const acc_2_balance = await this.token.balanceOf(accounts[2]);
			acc_2_balance.should.be.bignumber.equal(10);

			const acc_3_balance = await this.token.balanceOf(accounts[3]);
			acc_3_balance.should.be.bignumber.equal(10);
		});

		it("Multi value airdrop successful", async function() {
			//STEP 1 - SEND 50000 TOKENS TO THE AIRDROP CONTRACT ADDRESS
			await this.token.transfer(this.airdropContract.address, 50000, {from: accounts[0]});
			//STEP 2 - SEND 10, 20 & 30 TOKENS TO ACCOUNTS 1, 2 & 3 RESPECTIVELY
			//FROM ACCOUNT 0.
			await this.airdropContract.multiValueAirdrop(
				[accounts[1],accounts[2],accounts[3]],
				[10, 20, 30],
				{from: accounts[0]}
			);
			//STEP 3 - CHECK THAT THE TOKEN BALANCES OF ACCOUNTS 1, 2, & 3 
			//ARE NOW 10, 20 & 30.
			const acc_1_balance = await this.token.balanceOf(accounts[1]);
			acc_1_balance.should.be.bignumber.equal(10);

			const acc_2_balance = await this.token.balanceOf(accounts[2]);
			acc_2_balance.should.be.bignumber.equal(20);

			const acc_3_balance = await this.token.balanceOf(accounts[3]);
			acc_3_balance.should.be.bignumber.equal(30);
		});

		it("Owner able to withdraw tokens", async function() {
			//STEP 1 - SEND 50000 TOKENS TO THE AIRDROP CONTRACT ADDRESS
			await this.token.transfer(this.airdropContract.address, 50000, {from: accounts[0]});
			//STEP 2 - WITHDRAW 10000 TOKENS FROM THE AIRDROP CONTRACT
			await this.airdropContract.withdrawTokens(accounts[0], 10000, {from: accounts[0]});
			//STEP 3 - CHECK THAT THE TOKEN BALANCE OF THE AIRDROP CONTRACT
			//IS NOW 40000
			airdropContractBalance = await this.token.balanceOf(this.airdropContract.address);
			airdropContractBalance.should.be.bignumber.equal(40000);
		})
	})
})