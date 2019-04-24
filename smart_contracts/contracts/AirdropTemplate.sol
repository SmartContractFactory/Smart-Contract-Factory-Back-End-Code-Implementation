pragma solidity ^0.5.0;

import "./InterfaceERC20.sol";
import "./Owned.sol";

contract AirdropTemplate is Owned {
    
    InterfaceERC20 public token;
    
    /**
    * Creates a token object which points to the token on the Ethereum blockchain using 
    * the token's contract address. The constructor also assigns the owner of the contract
    * to be the address from the the transaction originated.
    * 
    * @param _tokenAddress - The address of the token which will be getting airdropped. 
    * @param _owner - The wallet address of the owner of the contract. 
    * */
    constructor(address _tokenAddress, address _owner) public {
        //Take the address of the erc20 token and create an instance of InterfaceERC20
        //which will be the object from which the token's transfer function will be invoked
        //(many times in a single transaction) for the airdrop. 
        token = InterfaceERC20(_tokenAddress);
        //Pass the owner's address (i.e., the one who is creating the airdrop contract) to
        //the Owned.sol smart contract. This is done because only the owner will be allowed
        //to airdrop tokens so it is important to at least know the owner's ETH address. 
        assignOwner(_owner);
    }
    
    
    /**
    * Allows the owner to airdrop tokens to multiple recipients were each recipient can receive
    * a different amounts of tokens. 
    * 
    * @param _recipientAddresses - The wallet addresses of the recipients.
    * @param _tokensToSend - The corresponding amounts of tokens to send to each recipient.
    * */
    function multiValueAirdrop(address[] memory _recipientAddresses, uint[] memory _tokensToSend) public onlyOwner {
        //Here we make a check (much like an assertion) to ensure that the length of the arrays of 
        //both arguments are of the same size. If not exit the function. 
        require(_recipientAddresses.length == _tokensToSend.length, "Address and value arrays must be of the same length");
        //Now iterate over one of the arrays (doesn't matter which as they are both of the same size).
        for(uint i = 0; i < _recipientAddresses.length; i++) {
            if(_recipientAddresses[i] != address(0x0)) {
                //If the address in the _recipientAddresses[i] is not of the form "0x00...00"
                //then transfer the corresponding amount of tokens to that address from the 
                //_tokensToSend array in the same index. 
                token.transfer(_recipientAddresses[i], _tokensToSend[i]);
            }
        }
    }
    
    
    /**
    * Allows the owner to airdrop tokens to multiple recipients were each recipient receives 
    * the same amount of tokens. 
    * 
    * @param _recipientAddresses - The wallet addresses of the recipients.
    * @param _tokensToSend - The total amount of tokens to send to all recipients.
    * */
    function singleValueAirdrop(address[] memory _recipientAddresses, uint _tokensToSend) public onlyOwner {
        //For the single value airdrop we just iterate over the _recipientAddresses array and
        //send the same amount of tokens to each address. 
        for(uint i = 0; i < _recipientAddresses.length; i++) {
            if(_recipientAddresses[i] != address(0x0)) {
                //If the address in the _recipientAddresses[i] is not of the form "0x00...00"
                //then transfer the tokens to the address. 
                token.transfer(_recipientAddresses[i], _tokensToSend);
            }
        }
    }
    
    
    /**
    * Allows the owner to withdraw tokens from the Airdrop contract. 
    * 
    * @param _recipientAddress - The address to send the tokens to.
    * @param _tokensToWithdraw - The total amount of tokens to withdraw. 
    * */
    function withdrawTokens(address _recipientAddress, uint _tokensToWithdraw) public onlyOwner {
        token.transfer(_recipientAddress, _tokensToWithdraw);
    }



    /**
    * Allows anyone to query the address of the token which the airdrop 
    * contract will be distributing.
    **/
    function getTokenAddress() public view returns(address) {
        return address(token);
    }
}
