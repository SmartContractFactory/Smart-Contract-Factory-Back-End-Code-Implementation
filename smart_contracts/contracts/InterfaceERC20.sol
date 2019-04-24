
pragma solidity ^0.5.0;

contract InterfaceERC20 {
	//Allows for the transfer of tokens from one account to another.
    function transfer(address _to, uint256 _value) external returns (bool);

    //Allows users to grant an allowance to others to spend up to a specified amount
    //of tokens on behalf of the users.
    function approve(address _spender, uint256 _value) external returns (bool);

    //Allows those who have been granted to spend tokens on behalf of others to actually
    //transfer the tokens.
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    //Returns the balance of a queried ETH address.
    function balanceOf(address _addr) external view returns (uint256);

    //Returns the approved allowance from an owner address to a spender address.
    function allowance(address _owner, address _spender) external view returns (uint256);

    //Events are triggered when a transfer or approval function has been executed. 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}






