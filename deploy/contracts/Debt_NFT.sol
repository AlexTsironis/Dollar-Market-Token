pragma solidity ^0.8.6;

import {ERC721} from './openzeppelin-contracts-master/contracts/token/ERC721/ERC721.sol';
import {USD} from "./USD.sol";

contract Debt_NFT is ERC721 {

    uint total_to_return;
    uint left_to_return;

    address factory;

    constructor(

        address mintTo,
        uint toReturn

    )

    ERC721("StableToken_Debt_NFT", "Stable")
    {

        _mint(mintTo, 1);

        total_to_return = toReturn;
        left_to_return = toReturn;
        factory = msg.sender;

    }

    function getOwner() public view returns (address){
        return this.ownerOf(1);
    }

    function leftToPay() public view returns (uint){
        return left_to_return;
    }

    function pay(uint amt) public returns (bool){
        require(msg.sender == factory);
        require(amt <= left_to_return);

        left_to_return -= amt;

        return true;

    }

}

