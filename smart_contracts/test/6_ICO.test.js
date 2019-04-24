const BigNumber = web3.BigNumber;

const truffleAssert = require('truffle-assertions');
const ICOContract = artifacts.require("ICOTemplate");
const ERC20Template = artifacts.require("ERC20Template");

//Chai is an assertion library
require("chai").use(require("chai-bignumber")(BigNumber)).should();


contract("ICO", accounts=> {



	const _totalSupply = 10000000e18;
	const _decimals = 18;
	const _name = "Test Token";
	const _symbol = "Test";
	const _isMintable = false;
	const _isBurnable = false;



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
		this.icoContract = await ICOContract.new(this.token.address, 18, 5e18, 500, 30, accounts[0]);
	});



	describe("UNIT TESTS", function() {

		it("ICO contract has correct token address", async function(){
			const tokenAddress = await this.icoContract.token();
			tokenAddress.should.equal(this.token.address);
		});



		it("ICO contract has soft cap of 5 ETH", async function(){
			const softCap = await this.icoContract.ethSoftCap();
			softCap.should.be.bignumber.equal(5e18);
		});



		it("ICO contract has a rate of 500", async function(){
			const rate = await this.icoContract.rate();
			rate.should.be.bignumber.equal(500);
		});



		it("Tokens sold starts at 0", async function(){
			const tokensSold = await this.icoContract.getTotalTokensSold();
			tokensSold.should.be.bignumber.equal(0);
		});



		it("Token purchase with fallback function works", async function(){
			//STEP 1 - SEND 5000000 TOKENS TO THE ICO CONTRACT ADDRESS
			await this.token.transfer(this.icoContract.address, 5000000, {from: accounts[0]});
			//STEP 2 - CHECK THAT THE ICO's ETH BALANCE STARTS AT 0
			const oldIcoBalance = await web3.eth.getBalance(this.icoContract.address);
			oldIcoBalance.should.be.bignumber.equal(0);
			//STEP 3 - SEND 35 WEI TO THE ICO CONTRACT ADDRESS
			await this.icoContract.sendTransaction({ 
		       value: 35, 
		       from: accounts[1], 
		       gas: 300000 
		    });
			//STEP 4 - CHECK THAT THE ICO's ETH BALANCE IS NOW 35 WEI
			const newIcoBalance = await web3.eth.getBalance(this.icoContract.address);
			newIcoBalance.should.be.bignumber.equal(35);
			//STEP 5 - CHECK THAT THE INVESTOR HAS RECEIVED THE CORRECT
			//AMOUNT OF TOKENS IN RETURN.
			const investorTokenBalance = await this.token.balanceOf(accounts[1]);
			investorTokenBalance.should.be.bignumber.equal(35 * 500);
		});



		it("ICO duration is correct", async function(){
			//STEP 1 - CHECK THAT THE ICO IS CURRENTLY ACTIVE
			icoEnded = await this.icoContract.icoHasEnded();
			icoEnded.should.equal(false);
			//STEP 2 - SEND THE EVM 30 DAYS INTO THE FUTURE USING SECONDS
			//AS THE ARGUMENT (IN THE UNIX TIME SYSTEM THERE IS 2592000 
			//SECONDS IN 30 DAYS).
			web3.currentProvider.send({
			  jsonrpc: "2.0", 
			  method: "evm_increaseTime", 
			  params: [2592001], 
			  id: 0
			});
			//STEP 3 - CHECK THAT THE ICO HAS NOW ENDED
			icoEnded = await this.icoContract.icoHasEnded();
			icoEnded.should.equal(true);
		});



		it("Able to claim refund when ICO ended & soft cap not reached", async function(){
			//STEP 1 - SEND 5000000 tokens TO THE ICO CONTRACT
			await this.token.transfer(this.icoContract.address, 5000000, {from: accounts[0]});
			//STEP 2 - SEND 33 WEI TO THE ICO CONTRACT
			await this.icoContract.sendTransaction({ 
		       value: 33, 
		       from: accounts[2], 
		       gas: 300000 
		    });
			//STEP 3 - CHECK THAT THE ICO CONTRACT HAS RECEIVED THE ETH.
			const oldIcoBalance = await web3.eth.getBalance(this.icoContract.address);
			oldIcoBalance.should.be.bignumber.equal(33);
			//STEP 4 - SEND THE EVM 30 DAYS INTO THE FUTURE USING SECONDS
			//AS THE ARGUMENT (IN THE UNIX TIME SYSTEM THERE IS 2592000 
			//SECONDS IN 30 DAYS).
			web3.currentProvider.send({
			  jsonrpc: "2.0", 
			  method: "evm_increaseTime", 
			  params: [2592001], 
			  id: 0
			});
			//STEP 5 - CLAIM THE REFUND.
			await this.icoContract.claimRefund({from:accounts[2]});
			//STEP 6 - CHECK THE BALANCE OF THE ICO IS 0 AFTER THE REFUND.
			const newIcoBalance = await web3.eth.getBalance(this.icoContract.address);
			newIcoBalance.should.be.bignumber.equal(0);
		});



		it("Able to claim refund when ICO is cancelled", async function(){
			//STEP 1 - SEND 5000000 tokens TO THE ICO CONTRACT
			await this.token.transfer(this.icoContract.address, 5000000, {from: accounts[0]});
			//STEP 2 - SEND 33 WEI TO THE ICO CONTRACT
			await this.icoContract.sendTransaction({ 
		       value: 33, 
		       from: accounts[2], 
		       gas: 300000 
		    });
		    //STEP 3 - CANCEL THE ICO
		    await this.icoContract.cancelICO({from:accounts[0]});
		    //STEP 4 - CLAIM REFUND
		    await this.icoContract.claimRefund({from:accounts[2]});
		    //STEP 5 - CHECK THAT THE ICO CONTRACT HAS 0 ETH
		    const icoBlanace =  await web3.eth.getBalance(this.icoContract.address);
		    icoBlanace.should.be.bignumber.equal(0);
		});



		it("Owner able to withdraw ETH when soft cap reached", async function(){
			//STEP 1 - SEND 5000000e18 TOKENS TO THE ICO CONTRACT
			await this.token.transfer(this.icoContract.address, 5000000e18, {from: accounts[0]});
			//STEP 2 - SEND  5 ETH TO THE ICO CONTRACT FROM ACCOUNT 2
			await this.icoContract.sendTransaction({ 
		       value: 5e18, 
		       from: accounts[2], 
		       gas: 300000 
		    });
			//STEP 3 - CHECK THAT THE ICO CONTRACT HAS RECEIVED THE 5 ETH.
			const oldIcoBalance = await web3.eth.getBalance(this.icoContract.address);
			oldIcoBalance.should.be.bignumber.equal(5e18);
			//STEP 4 - CHECK THE OWNER's CURRENT ETH BALANCE
			const oldOwnerBalance = await web3.eth.getBalance(this.icoContract.address);
			//STEP 5 - WITHDRAW THE ETH. 
			await this.icoContract.withdrawEth();
			//STEP 6 - CHECK ICO's BALANCE IS NOW 0 ETH
			const newIcoBalance = await web3.eth.getBalance(this.icoContract.address);
			newIcoBalance.should.be.bignumber.equal(0);
			//STEP 7 - CHECK THE OWNER's BALANCE IS NOW 105 ETH
			const newOwnerBalance = await web3.eth.getBalance(accounts[0]);
			newOwnerBalance.should.be.bignumber.greaterThan(oldOwnerBalance);
		});



		it("Owner is able to withdraw tokens", async function(){
			//STEP 1 - Send 5000000e18 TOKENS TO THE ICO CONTRACT
			await this.token.transfer(this.icoContract.address, 5000000e18, {from: accounts[0]});
			//STEP 2 - WITHDRAW 2500000e18 FROM THE ICO CONTRACT
			await this.icoContract.withdrawTokens(accounts[1], 2500000e18, {from: accounts[0]});
			//STEP 3 - CHECK THAT THE ICO's NEW TOKEN BALANCE IS 2500000e18
			const icoTokenBalance = await this.token.balanceOf(this.icoContract.address);
			icoTokenBalance.should.be.bignumber.equal(2500000e18);
			//STEP 4 - CHECK THAT accounts[1] HAS 2500000e18 TOKENS
			const acc_1_balance = await this.token.balanceOf(accounts[1]);
			acc_1_balance.should.be.bignumber.equal(2500000e18);
		});



		it("Owner able to change rate", async function() {
			//STEP 1 - CHECK THAT THE OLD RATE IS 500
			const oldRate = await this.icoContract.rate();
			oldRate.should.be.bignumber.equal(500);
			//STEP 2 - SET RATE TO 200
			await this.icoContract.changeRate(200);
			const newRate = await this.icoContract.rate();
			newRate.should.be.bignumber.equal(200);
		});



		it("Owner able to cancel ICO", async function() {
			//STEP 1 - CHECK THAT THE ICO IS NOT CANCELLED
			icoCancelled = await this.icoContract.icoCancelled();
			icoCancelled.should.equal(false);
			//STEP 2 - CANCEL THE CIO
			await this.icoContract.cancelICO();
			//STEP 3 - CHECK THAT THE ICO IS NOW CANCELLED 
			icoCancelled = await this.icoContract.icoCancelled();
			icoCancelled.should.equal(true);
		});



		it("Owner able to shorten deadline", async function() {
			//STEP 1 - GET CURRENT DEADLINE
			const oldDeadline = await this.icoContract.deadline();
			//STEP 2 - SHORTEN DEADLINE TO BE 1 SECOND FROM NOW
			await this.icoContract.shortenDeadline(1);
			//STEP 3 - GET THE NEW DEADLINE
			const newDeadline = await this.icoContract.deadline();
			//STEP 4 - CHECK THAT THE NEW DEADLINE IS LESS THAN 
			//THAN THE OLD DEADLINE
			newDeadline.should.be.bignumber.lessThan(oldDeadline);
		});



		it("Investor cannot claim refund more than once", async function(){
			//STEP 1 - SEND 5000000e18 TOKENS TO THE ICO CONTRACT
			await this.token.transfer(this.icoContract.address, 5000000e18, {from: accounts[0]});
			//STEP 2 - SEND  5 ETH TO THE ICO CONTRACT FROM ACCOUNT 1
			await this.icoContract.sendTransaction({ 
		       value: 5e18, 
		       from: accounts[1], 
		       gas: 300000 
		    });
			//STEP 3 - SEND  5 ETH TO THE ICO CONTRACT FROM ACCOUNT 2
			await this.icoContract.sendTransaction({ 
		       value: 5e18, 
		       from: accounts[2], 
		       gas: 300000 
		    });
		    //STEP 4 - CANCEL THE ICO
		    await this.icoContract.cancelICO({from:accounts[0]});
		    //STEP 5 - CLAIM FIRST REFUND
		    await this.icoContract.claimRefund({from:accounts[1]});
		    //STEP 6 - ATTEMPT TO CLAIM REFUND AGAIN FROM SAME ACCOUNT
		    await truffleAssert.reverts(this.icoContract.claimRefund({from:accounts[1]}));
		    //STEP 7 - CHECK THAT ICO CONTRACT STILL HAS 5 ETH
		    const icoBlanace = await web3.eth.getBalance(this.icoContract.address);
		    icoBlanace.should.be.bignumber.equal(5e18);
		    //STEP 8 - CLAIM REFUND FROUM accounts[2]
		    await this.icoContract.claimRefund({from:accounts[2]});
		});
	})
})