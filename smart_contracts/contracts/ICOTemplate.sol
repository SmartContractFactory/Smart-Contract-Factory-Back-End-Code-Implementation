pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./AddressMakePayable.sol";
import "./InterfaceERC20.sol";
import "./Owned.sol";


contract ICOTemplate is Owned {
    
    //Use the SafeMath library functions on the uint256 data type.
    using SafeMath for uint;
    
    //Use the AddressMakePayable library functions on the address data type
    using AddressMakePayable for address;
    
    
    /**
    * Will point to the token contract on the Ethereum blockchain
    * by the token's address. When instantiated, the token's functions 
    * will invoced from here. 
    **/
    InterfaceERC20 public token;
    
    uint public tokenDecimals;
    //ethSoftCap represents the minimum amount of ETH that needs to be raised for 
    //the ico to be a success. 
    uint public ethSoftCap;
    //The rate is how many tokens are issued per 1 ETH invested. 
    uint public rate;
    //The deadline is specified in days using Unix time 
    uint public deadline;
    //softCapReached will become true when the minimum minimum amount of ETH needed 
    //for the ICO to be a success has been raised.
    bool public softCapReached;
    //Will become true only if the owner of the ICO contract decides to cancel the ICO. 
    bool public icoCancelled; 
    //Will be updated everytime tokens are purchased. 
    uint public tokensSold;
    
    /**
    * This mapping will hold a record of all investments which invstors 
    * have made during the ICO. It will use the user's address as the key 
    * which will map to an unsigned integer representing the total investment 
    * made by the user in units of wei (1 wei * (10**18) = 1 ETH).
    * */
    mapping (address => uint) public investments;
    
    
    /**
    * Initializes the state variables of the ICO contract and also assigns the owner to 
    * be the address from which the transaction originated.
    * 
    * @param _tokenAddress - The contract address of the ERC20 token which will be on sale.
    * @param _tokenDecimals - The number of decimals of the ERC20 token
    * @param _ethSoftCap - The minimum amount of ETH that needs to be raised. 
    * @param _rate - The exchange rate of ETH to the token. 
    * @param _durationInDays - The total amount of days the ICO will be active for.
    * */
    constructor(address _tokenAddress, uint _tokenDecimals, uint _ethSoftCap, uint _rate, uint _durationInDays, address _owner) public {
        //Take the address of the erc20 token and create an instance of InterfaceERC20
        //which will be the object from which the token's transfer function will be invoked
        //when investors purchase tokens from this ICO contract. 
        token = InterfaceERC20(_tokenAddress);
        tokenDecimals = _tokenDecimals;
        ethSoftCap = _ethSoftCap;
        rate = _rate;
        deadline = now.add(_durationInDays.mul(1 days));
        softCapReached = false;
        icoCancelled = false;
        tokensSold = 0;
        //Pass the owner's address (i.e., the one who is creating the ICO contract) to
        //the Owned.sol smart contract. This is done because only the owner will be allowed
        //to invoke certain functions (look at the onlyOwner modifier in the Owned.sol contract)
        assignOwner(_owner);
    }
    
    
    /**
    * Event is broadcast to the Ethereum blockchain to signify 
    * that a token purchase has just been made. 
    * */
    event TokensPurchased (
        address indexed by,
        uint totalTokensPurchased
    );
    
    
    /**
    * Allows anyone to query the total amount of tokens sold on the ICO 
    * contract.
    *
    * @return The total amount of tokens sold. 
    * */
    function getTotalTokensSold() public view returns(uint) {
        return tokensSold;
    }


    /**
    * Allows anyone to query if the ICO has ended. 
    *
    * @return True if the ICO deadline has passsed, or if the ICO has 
    * been cancelled. False otherwise. 
    **/
    function icoHasEnded() public view returns(bool) {
        return (now > deadline || icoCancelled);
    }



    /**
    * Allows anyone to query the contract address of the ERC20 token 
    * on sale. 
    *
    * @return The contract address of the ERC20 token on sale. 
    **/
    function getTokenAddress() public view returns(address) {
        return address(token);
    }
    
    
    /**
    * This is a fallback function which is only ever invoced at the time 
    * when the address of the ICO contract receives ETH. This is because
    * when ETH is sent to the contract address, the EVM will look to 
    * execute a function and when it does not find a suitable function 
    * it will default to the fallback function. 
    * 
    * It is also worth noting that this function is a payable function 
    * meaning that the function accepts ETH. Without any payable functions 
    * in a smart contract, the contract cannot store any ETH sent to it. 
    * 
    * This function allows investors to simply send ETH to the ICO contract 
    * address and they will automatically receive tokens to the same address 
    * of which they sent ETH from. This is because this fallback function 
    * invoces the 'buyTokens' funciton and passes through msg.sender as the 
    * argument (this means the address of the investor).
    **/
    function() external payable {
        buyTokens(msg.sender);
    }
    
    
    
    /**
    * Allows investors to buy tokens with ETH. This function is a special 
    * type of function because it has the 'payable' modifier meaning that 
    * it is a function that accepts ETH as part of the function invocation. 
    * The ETH that is received as part of the transaction is taken into 
    * account and the tokens to be sent to the investor in return is 
    * calculated at the given exchange rate set by the owner of the contract. 
    * 
    * This function can either be invoced manually, or it can be invoced 
    * internally by the fallback function of the contract. In 99% of cases
    * the function will be invoced by the fallback function (described above). 
    * 
    * @param _investor - The address of the investor of which the tokens 
    * purchased shall be sent to. 
    * */
    function buyTokens(address _investor) public payable {
        //First check that the _investor address provided is not of the form 0x00...00
        require(_investor != address(0x0), "The investor address cannot be 0x00...00");
        //Next check that the ICO is still active. 
        require(!icoHasEnded(), "The deadline has passed or the ICO has been cancelled");
        //Calculate how many tokens need to be sent to the investor based on the total 
        //amount of ETH the investor sent to the ICO contract. 
        uint tokensPurchased = (rate.mul(msg.value)).div(uint(1e18).div(10**tokenDecimals));
        //Now send the tokens to the investor. 
        token.transfer(_investor, tokensPurchased);
        //Broadcast the token purchase event to the Ethereum network.
        emit TokensPurchased(
            _investor, 
            tokensPurchased
        );
        //Now check if the soft cap has been reached. 
        if(address(this).balance >= ethSoftCap && !softCapReached) {
            //When this condition is met the owner of the ICO contract will be
            //allowed to withdraw all the ETH from the contract. 
            softCapReached = true;
        }
        //Update the variable with the total amount of tokens sold.
        tokensSold = tokensSold.add(tokensPurchased);
        //Update the investments mapping from the investor's address.
        //This is done incase the ICO fails or is cancelled, the investor 
        //will be able to claim a full refund using this mapping. 
        investments[_investor] = investments[_investor].add(msg.value);
    }

    
    /**
    * Allows investors to claim a refund if the softcap has not been 
    * reached before the deadline, or if the ICO has been cancelled 
    * by the owner. 
    * */
    function claimRefund() public {
        //Check if the ICO deadline has passed and the soft cap has 
        //not been reached, or if the ICO has been cancelled. 
        require(!softCapReached && icoHasEnded() || icoCancelled, "No refunds possible at this time");
        //Important to check that the investmet of the user claiming a refund 
        //is greater than 0.
        require(investments[msg.sender] > 0);
        //This variable assignment of the user's investment is very important 
        //as it mitigates the possibilty of a reentrancy attack. For example,
        //an attacker could create a smart contract and send ETH from the smart 
        //contract to this ICO contract. The attacker will have created a loop
        //in the smart contract to claim a refund many times in a single transaction
        //draining this contract by taking advantage of a race condition. 
        uint toRefund = investments[msg.sender];
        //Now we set the investments mapping with the investor's address to be 0.
        //At this point a reentrancy attack is not possible due to the second 
        //requirement above. 
        investments[msg.sender] = 0;
        //Now send the full ETH refund to the user. 
        msg.sender.transfer(toRefund);
    }
    
    
    /**
     * Allows the owner of the contract to withdraw all the ETH which is 
     * in the contract given that the softcap has been reached prior to 
     * the deadline and also if the owner of the contract did not cancel 
     * the ICO. 
     **/
    function withdrawEth() public onlyOwner {
        //Check that the soft cap has been reached and that the ICO has
        //not been cancelled before allowing the owner to withdraw the 
        //ETH in the contract. 
        require(softCapReached && !icoCancelled, "Withdrawals not possible at this time");
        //Now send all the ETH in the smart contract to the owner. 
        getOwner().makePayable().transfer(address(this).balance);
    }
    
    
    /**
    * Allows the owner of the ICO to withdraw tokens from the contract.
    * 
    * @param _to - The address to send the tokens to.
    * @param _tokensToWithdraw - The amount of tokens to withdraw. 
    **/
    function withdrawTokens(address _to, uint _tokensToWithdraw) public onlyOwner {
        token.transfer(_to, _tokensToWithdraw);
    }
    
    
    /**
    * Allows the owner of the contract to set a new exchange rate at which 
    * tokens will be sold. 
    * 
    * @param _newRate - The new exchange rate. 
    **/
    function changeRate(uint _newRate) public onlyOwner {
        //Check that the owner has provided a value which is greater than 0.
        require(_newRate > 0, "The new rate must be greater than zero");
        rate = _newRate;
    }
    
    
    /**
    * Allows the owner of the ICO contract to cancel the ICO. 
    **/
    function cancelICO() public onlyOwner {
        icoCancelled = true;
    }
    
    
    /**
    * Allows the owner of the contract to shorten the deadline of the ICO.
    * 
    * @param _newDeadline - The new deadline in days from the moment of 
    * invocation.
    * */
    function shortenDeadline(uint _newDeadline) public onlyOwner {
        //Check that the new deadline is earlier than the old deadline. 
        require(now.add(_newDeadline.mul(1 days)) < deadline);
        deadline = now.add(_newDeadline.mul(1 days));
    }
}
