pragma solidity ^0.8.6;

import {ERC20} from "./openzeppelin-contracts-master/contracts/token/ERC20/ERC20.sol";

contract StableToken is ERC20 {
    constructor() ERC20("StableToken", "StableToken") {
        _mint(msg.sender, 2**255);
    }
}
