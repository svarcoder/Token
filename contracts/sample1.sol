//SPDX-License-Identifier: Unlicenseed 
pragma solidity 0.5.16;

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
import "./libraries/SafeMath.sol";

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

import "./libraries/Ownable.sol";
import "./libraries/ERC20.sol";


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

 contract Sample1 is Ownable, ERC20 {
    using SafeMath for uint;
    address public admin;

    constructor() public ERC20("YTH", "YTH"){
        admin = msg.sender;
    }

    event deposited(address user, uint amount);
    event withdrawn(address user, uint yAmount);

    mapping(address => uint) public wallet;

    modifier defense {
        require(msg.sender == admin, "Only owner can");    //Modifier
        _;
    }

    function deposit() external payable defense {
        _deposit(msg.sender, msg.value);
    }

    function _deposit(address user, uint amount) internal {
        require(user != address(0), "User can not be zero");
        require(amount !=0, "amount should not be zero");
        _mint(user, amount);
        wallet[user] = wallet[user].add(amount);    //SafeMath
        emit deposited(user, amount);
    }

    function withdraw(uint yAmount) external{
         _withdraw(msg.sender, yAmount);
    }

    function _withdraw(address payable user, uint yAmount) internal {
        require(user != address(0), "User can not be zero");
        require(yAmount !=0, "amount should not be zero");
        wallet[user] = wallet[user].sub(yAmount);          //Safemath
        user.transfer(yAmount);
        //require(sent, "Failed");
        _burn(user, yAmount);
        emit withdrawn(user, yAmount);
    }
 }