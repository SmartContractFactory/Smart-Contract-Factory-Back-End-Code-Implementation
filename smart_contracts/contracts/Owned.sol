pragma solidity ^0.5.0;

contract Owned {
    
    //Holds the address of the current owner of the contract. 
    address private owner;
    

    /**
     * Event is broadcast to the Ethereum blockchain to signify 
     * that a new owner has been assigned. 
     * */
    event OwnershipTransferred(
        address indexed from,
        address indexed to
    );
    
       
    /**
     * Any function with this modifier can only be invoked by the 
     * owner of this contract and all other contracts whcih inherit 
     * this contract. 
     * */
    modifier onlyOwner {
        require(msg.sender == owner, "msg.sender is not the owner");
        _;
    }
    
   
    /**
     * Returns the ETH address of the owner of any contract which 
     * inherits this contract.
     * 
     * @return The address of the owner.
     * */
    function getOwner() public view returns(address) {
        return owner;
    }
    
    
    /**
     * Initializes the owner variable with an address (can only be invoked once). 
     * */
    function assignOwner(address _owner) public {
        //Make sure the owner has not already been initialized.
        require(owner == address(0x0));
        owner = _owner;
    }
    

    /**
     * Allows the current owner of the contract and all contracts 
     * which inherit this contract to transfer ownership to another 
     * ETH address. This function can only be invoked by the owner 
     * of the contract. 
     * 
     * @param _newOwner - The address of the new owner. 
     * */
    function transferOwnership(address _newOwner) public onlyOwner {
        //Check that the address is not 0x00.....00
        require(_newOwner != address(0x0), "The new owner's address cannot be 0x00...00");
        //Broadcast the transfer of ownership event to the Ethereum network.
        emit OwnershipTransferred(
            owner,
            _newOwner
        );
        owner = _newOwner;
    }
}
