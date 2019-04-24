pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./InterfaceERC20.sol";
import "./Owned.sol";

contract ERC20Template is InterfaceERC20, Owned {
    
    //Use the SafeMath library functions on the uint256 data type.
    using SafeMath for uint;
    
    /**
    * This mapping will hold a record of user balances by using the user's address 
    * as the key which maps to an unsigned integer representing the balance.  
    * */
    mapping (address => uint) private balances;
    
    /**
    * This mapping will hold a recored of allowances made (i.e., address A has allowed 
    * address B to spend up to X amount of tokens from address A's wallet). In this
    * mapping there are two keys, A & B which would yield the following [A][B] -> X
    * where X is an unsigned integer value representing the allowance from address A to B. 
    **/
    mapping (address => mapping (address => uint)) allowances;
    
    //This is the total amount of tokens.
    uint public totalSupply;
    //This represents how many decimals the token will have (18 is the standard).
    uint8 public decimals;
    //This is where the name of the token will be stored.
    string public name;
    //This is where the ticker of the token will be stored. 
    string public symbol;
    //The below variables will be used for determining if a token will be 
    //mintable, burnable, or both. 
    bool public isMintable;
    bool public isBurnable;
    
    /**
     * Initializes the state variables of the token contract, assigns the owner to be 
     * the address from which the transaction originated and also sends all tokens to 
     * the owner.
     * 
     * @param _totalSupply - The total amount of tokens. 
     * @param _decimals - The number of decimals of the token.
     * @param _name - The name of the token.
     * @param _symbol - The ticker of the token.
     * */
    constructor(uint _totalSupply, uint8 _decimals, string memory _name, string memory _symbol, bool _isMintable, bool _isBurnable, address _owner) public {
        totalSupply = _totalSupply;
        decimals = _decimals;
        name = _name;
        symbol = _symbol;
        isMintable = _isMintable;
        isBurnable = _isBurnable;
        //Pass the owner's address (i.e., the one who is creating the ERC20 contract) to
        //the Owned.sol smart contract. This is done because only the owner will be allowed
        //to invoke certain functions (look at the onlyOwner modifier in the Owned.sol contract)
        assignOwner(_owner);
        //Send the entire total supply of tokens to the owner. 
        balances[getOwner()] = totalSupply;
        //Broadcast the token transfer event to the Ethereum network 
        //(because the owner has been given all the tokens). 
        emit Transfer(
            address(0x0),
            getOwner(),
            totalSupply
        );
    }
    
    
    /**
    * Event is broadcast to the Ethereum blockchain to signify 
    * that an approval has been made.
    * */
    event Approval(
        address indexed owner, 
        address indexed spender, 
        uint value
    );
    
    
    /**
    * Event is broadcast to the Ethereum blockchain to signify 
    * that a transfer of tokens has take place.
    * */
    event Transfer(
        address indexed from, 
        address indexed to, 
        uint value
    );

    
    /**
    * Allows anyone to query the balance of a given address.
    * 
    * @param _addr - The address of which the balance is being queried.
    * 
    * @return The balance of the address.
    * */
    function balanceOf(address _addr) external view returns (uint) {
        return balances[_addr];
    }
    
    
    /**
    * Allows anyone to query the token contract to see how many tokens an owner 
    * of tokens has allowed a spender to spend from the owner's balance. 
    * 
    * @param _owner - The address which the tokens reside in. 
    * @param _spender - The address of the spender. 
    * 
    * @return The total amount of tokens the spender is allowed to spend from
    * the owner's tokens.
    * */
    function allowance(address _owner, address _spender) external view returns (uint) {
        return allowances[_owner][_spender];
    }

    
    /**
    * Invoked internally by the transfer & transferFrom function to avoid 
    * duplication of code. 
    * 
    * @param _from - The address the tokens will leave from. 
    * @param _to - The recipient of the tokens. 
    * @param _value - The total amount of tokens which will be sent. 
    * */
    function internalTranfer(address _from, address _to, uint _value) internal {
        //Check that the person invoking the function has enough tokens to transfer.
        require(balances[_from] >= _value, "From address does not have enough tokens");
        //Check that the address is not 0x00.....00
        require(_to != address(0x0), "The recipient address must not be 0x00...00");
        //Subtract tokens from the person's ETH address.
        balances[_from] = balances[_from].sub(_value);
        //Add tokens to the recipient's ETH address.
        balances[_to] = balances[_to].add(_value); 
        //Broadcast the token transfer event to the Ethereum network 
        emit Transfer(
            _from,
            _to,
            _value
        );
    }


    /**
    * Allows token holders to tranfer their tokens to other ETH addresses. 
    * 
    * @param _to - The recipient address which will receive the tokens.
    * @param _value - The total amount of tokens which will be sent.
    * 
    * @return True if the function executes successfully, false otherwise. 
    * */
    function transfer(address _to, uint _value) external returns (bool) {
        internalTranfer(msg.sender, _to, _value);
        return true;
    }

    
    /**
    * Invoked internally by the approve and transferFrom function. 
    * 
    * @param _owner - The address of the owner of the tokens.
    * @param _spender - The address of the spender of the tokens. 
    * */
    function internalApprove(address _owner, address _spender, uint _value) internal {
        //Check that _owner & _spender is not 0x00.....00
        require(_spender != address(0x0), "The spender address must not be 0x00...00");
        require(_owner != address(0x0), "The owner address must not be 0x00..00");
        //Assign the new allowance value to the allowances mapping
        //from owner to spender
        allowances[_owner][_spender] = _value;
        //Broadcast the token approval event to the Ethereum network 
        emit Approval(
            _owner, 
            _spender, 
            _value
        );
    }    
    
    
    /**
    * Allows an owner of tokens to approve some spender to spend up 
    * to a specified amount of tokens from the owner's wallet address. 
    * 
    * @param _spender - The address of the spender who will be allowed to 
    * spend tokens from the owner's wallet address. 
    * @param _value - The total amount of tokens the owner will allow the 
    * spender to spend.
    * 
    * @return True if the function executes successfully, false otherwise.  
    * */
    function approve(address _spender, uint _value) external returns(bool) {
        internalApprove(msg.sender, _spender, _value);
        return true;
    }
    
    
    /**
    * Allows a spender who has been approved by an owner of the token to 
    * spend tokens from the owner's wallet address. 
    * 
    * @param _from - The wallet address of the owner. 
    * @param _value - The total amount of tokens to transfer. 
    * 
    * @return True if the function executes successfully, false otherwise. 
    * */
    function transferFrom(address _from, address _to, uint _value) external returns (bool) {
        //Check that the spender has a high enough allowance from the owner.
        require(allowances[_from][msg.sender] >= _value, "The spender does not have a sufficient allowance");
        //Invoke the internal transfer function to move the tokens from the 
        //owner's wallet address to the recipients wallet address. 
        internalTranfer(_from, _to, _value);
        //Invoke the internal approval function to update the allowance 
        //of the owner to the spender. 
        internalApprove(_from, msg.sender, allowances[_from][msg.sender].sub(_value));
        return true;
    }
    
    
    /**
    * Allows the owner of the contract to burn tokens from the total supply 
    * if and only if the token was declared as a burnable one in the constructor
    * of the contract. 
    * 
    * @param _value - The total amount of tokens to burn. 
    * 
    * @return True if the function executes successfully, false otherwise. 
    **/
    function burnTokens(uint _value) public onlyOwner returns(bool){
        //Check that the token was declared as a burnable one upon 
        //initialization in the constructor.
        require(isBurnable, "Token is not burnable");
        //Decrement the total supply.
        totalSupply = totalSupply.sub(_value);
        //Remove the tokens from the owner's balance.
        balances[getOwner()] = balances[getOwner()].sub(_value);
        //Broadcast the token burn event to the Ethereum network as 
        //a transfer from the owners address to the 0x00...00 address. 
        emit Transfer(getOwner(), address(0x0), _value);
        return true;
    }
    
    
    /**
     * ALlows the owner of the contract to mint new tokens to any wallet 
     * address if and only if the token was declared as a mintable one in 
     * the constructor of the contract. 
     * 
     * @param _to - The address of the recipient.
     * 
     * @return True if the function executes successfully, false otherwise. 
     * */
    function mintTokens(address _to, uint _value) public onlyOwner returns(bool) {
        //Check that the token was declared as a mintable one upon 
        //initialization in the constructor. 
        require(isMintable, "Token is not mintable");
        //Check that the _to address is not of the form 0x00...00.
        require(_to != address(0x0), "The recipient address must not be 0x00...00");
        //Add the tokens to the total supply.
        totalSupply = totalSupply.add(_value);
        //Add the tokens to the _to address's balance.
        balances[_to] = balances[_to].add(_value);
        //Broadcast the token minting event to the Ethereum network as 
        //a transfer from the 0x00...00 address to the _to address. 
        emit Transfer(address(0x0), _to, _value);
        return true;
    }
}
