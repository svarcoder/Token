// SPDX-License-Identifier: UNLICENSED

pragma solidity ^ 0.5.16;
import "./libraries/SafeMath.sol";
import "./libraries/Ownable.sol";   //the contract should be ownable and context is inherited in ownable contract

/**
  SafeMath is a solidity math library especially designed to support safe math operations: 
  safe means that it prevents overflow when working with uint. 

  Wrappers over Solidity’s arithmetic operations with added overflow checks.

  Arithmetic operations in Solidity wrap on overflow. This can easily result in bugs, 
  because programmers usually assume that an overflow raises an error, 
  which is the standard behavior in high level programming languages.  
  SafeMath restores this intuition by reverting the transaction when an operation overflows.

  Using this library instead of the unchecked operations eliminates an entire class of bugs, 
  so it’s recommended to use it always.

  Note: In the newer version of solidity above 8.0 there is no required of safeMath library anymore. 
        for more you can check below link
        https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
*/




/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
   When using a meta-transaction solution such as EIP-2771, msg.sender will be 
   a forwarder account, and the “real” message sender has to be retrieved through other means.
 */
/**
  Note: It seem doing exactly the same thing with msg.sender.
        So if for some reason msg.sender becomes obsolete, 
        it's just a matter of changing one line instead of multiple lines 
        throughout multiple contracts (and possibly forgetting about some).
        "_msg.sender here allows a recipient contract to retrieve the original 
        sender in the case of a meta-transaction sent by a trusted forwarder."
*/


/**
Modifier: 
   Function Modifiers are used to modify the behaviour of a function. 
   1)It is defined usin "modifier" ketword.
   2)The code foe modifier is placed within curly brackets.
   3)The code within a modofier can validate the incoming value and can conditionally excexute the called function after evaluation.
   4)The modifier can be applied to multiple functions.
   The function body is inserted where the special symbol "_;" appears 
   in the definition of a modifier. So if condition of modifier is satisfied
   while calling this function, the function is executed and otherwise, an exception is thrown.
 */


contract CoinWallet is Ownable {
    using SafeMath for uint256;

    address public Miner; //indicate the address of the miner 
    
    constructor() public {
        Miner = msg.sender;
    }
   
   enum Action {Transfered, NotTransfered, Deposited, NotDeposited, Used, NotUsed}
   Action Status;

   Action constant defaultAction = Action.NotTransfered;

    mapping(address => bool) public usersWhitelisted;  
    mapping (address => uint256) public AvailableCoins;
  
    event Sent_Coin(address from, address to, uint256 coins);
    

    address collector;
    function MineCoins(address _collector, uint256 coins) public {
        collector = _collector;
        require(msg.sender == Miner ,"Only Miner can Mine");
        AvailableCoins[collector] = AvailableCoins[collector].add(coins);
    }


    function CollectorStatus() public view returns(Action) {
       if(AvailableCoins[collector] != 0) {
        return Action.Transfered;
    } else {
       return Action.NotTransfered;
       }
    }

    modifier whitelistedUsers {
        require(usersWhitelisted[msg.sender] == true, "user is not whitelisted");    //modifier
        _;
    }


    event LessCoins(uint256 requested, uint256 Available);
    event RecipientNotValid();


    function doWhitelist(address newAddress) external {
        usersWhitelisted[newAddress] = true;
    }

    address recipient;
    function Send_Coins(address _recipient, uint256 coins) public whitelistedUsers {
        recipient = _recipient;
        if(coins > AvailableCoins[msg.sender])
         // Errors that describe failures.
        emit LessCoins({
            requested : coins,
            Available : AvailableCoins[msg.sender]
        });
        if(recipient == msg.sender)
        emit RecipientNotValid();
    AvailableCoins[msg.sender] =  AvailableCoins[msg.sender].sub(coins);
    AvailableCoins[recipient] = AvailableCoins[recipient].add(coins);
    emit Sent_Coin(msg.sender, recipient, coins);
    }
    
    

    function RecipientStatus() public view returns(Action) {
       if(AvailableCoins[recipient] != 0) {
        return Action.Deposited;
       } else {
           return Action.NotDeposited;
       }
    }
    
    
    function DisplayCollectorWallet() external view returns(uint) {
          return AvailableCoins[msg.sender];
    }
     

    function DisplayRecipientWallet() external view returns(uint) {
          return AvailableCoins[recipient];
    }
}