const BigNumber = web3.BigNumber;

const ContractFactory = artifacts.require("ContractFactory");
const ERC20Template = artifacts.require("ERC20Template");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();


contract("CONTRACT FACTORY", accounts=> {

	/**
	* This creates a new instance of the Smart Contract Factory for
	* every unit test.
	**/
	beforeEach(async function() {
		 this.contractFactory = await ContractFactory.new();
	});

	//If no error is thrown during the deployment of a smart contract, then 
	//this is an indication that the test has passed.
	describe("UNIT TESTS", function() {

		it("Contract factory is able to deploy simple token", async function() {
			await this.contractFactory.deploySimpleToken(500e18,18,"Test Token","Test",{from:accounts[0]});
		});

		it("Contract factory is able to deploy mintable token", async function() {
			await this.contractFactory.deployMintableToken(500e18,18,"Test Token","Test",{from:accounts[0]});
		});

		it("Contract factory is able to deploy burnable token", async function() {
			await this.contractFactory.deployBurnableToken(500e18,18,"Test Token","Test",{from:accounts[0]});
		});

		it("Contract factory is able to deploy mintable & burnable token", async function() {
			await this.contractFactory.deployMintableBurnableToken(500e18,18,"Test Token","Test",{from:accounts[0]});
		});

		it("Contract factory is able to deploy airdrop contract", async function() {
			token = await ERC20Template.deployed();
			await this.contractFactory.deployAirdropContract(token["address"],{from:accounts[0]});
		});

		it("Contract factory is able to deploy ICO contract", async function() {
			token = await ERC20Template.deployed();
			await this.contractFactory.deployICOContract(token["address"],18,500e18,200,30,{from:accounts[0]});
		});
	})
})