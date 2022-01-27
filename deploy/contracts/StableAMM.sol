pragma solidity ^0.8.6;

import {USD} from "./USD.sol";
import {StableToken} from "./StableToken.sol";
import {Debt_NFT} from "./Debt_NFT.sol";

contract StableAMM {

    uint public balanceUSD;
    USD public addressUSD;

    uint public balanceStable;
    StableToken public addressStable;

    uint public treasuryUSD;

    mapping(uint => Debt_NFT) public debtOrder;
    uint public indexDebt;
    uint public totalDebt;

    uint public epsilon;
    uint public proportionToExpand;
    uint public minimalDebtToPay;

    constructor (USD adrUSD, StableToken adrToken){

        addressUSD = adrUSD;
        balanceUSD = 10000000000000000000000000;

        addressStable = adrToken;
        balanceStable = 10000000000000000000000000;

        indexDebt = 0;
        totalDebt = 0;
        treasuryUSD = 100000000000000000000000;

        epsilon = 50;
        proportionToExpand = 50;
        minimalDebtToPay = 1000000000000000000;

    }

    function swapAMM(uint numUSD, uint numStable) public view returns (uint){
        require(numUSD != 0 || numStable != 0);

        if (numUSD == 0) {
            return numStable * balanceUSD / (balanceStable + numStable);
        }

        return numUSD * balanceStable / (balanceUSD + numUSD);

    }

    function payDebt() public returns (bool){

        if (indexDebt != totalDebt && treasuryUSD >= minimalDebtToPay) {

            uint left = debtOrder[indexDebt].leftToPay();
            uint amtPay = (left <= treasuryUSD) ? left : treasuryUSD;
            treasuryUSD -= amtPay;
            if (left <= treasuryUSD) {indexDebt ++;}

            debtOrder[indexDebt].pay(amtPay);
            addressUSD.transfer(debtOrder[indexDebt].getOwner(), amtPay);

            return true;

        }

        return false;
    }

    function treasuryToBalance() public returns (bool){
        if (balanceUSD  < balanceStable - balanceStable*epsilon / 1000) {
            uint change = balanceStable - balanceUSD;
            change = change < treasuryUSD ? change : treasuryUSD;

            balanceUSD += change;
            treasuryUSD -= change;
            return true;

        }

        return false;

    }

    function acceptDebt(uint balanceToAdd) public returns (bool){

        require(treasuryUSD == 0);
        require(addressUSD.allowance(msg.sender, address(this)) >= balanceToAdd);

        uint to_return = swapAMM(balanceToAdd, 0);
        require(balanceToAdd < to_return * (1 - epsilon / 1000));

        addressUSD.transferFrom(msg.sender, address(this), balanceToAdd);

        totalDebt++;
        debtOrder[totalDebt - 1] = new Debt_NFT(msg.sender, to_return);

        balanceUSD += balanceToAdd;

        return true;

    }

    function extraUsd() public returns (bool){
        if (balanceUSD  > balanceStable + balanceStable * epsilon / 1000) {
            uint change = balanceUSD - balanceStable - balanceStable * epsilon / 1000;
            uint toSave = change;// * proportionToExpand / 100;
            

            treasuryUSD += toSave;
            balanceUSD -= toSave;
           // balanceStable = balanceUSD * 1000 / (1000 + epsilon);

            payDebt();

            return true;
        }

        return false;
    }

    function swap(uint usd, uint token) public returns (bool){
        // one way swap only
        require(usd == 0 || token == 0);

        // ensuring that the money are in
        if (usd == 0) {
            require(addressStable.allowance(msg.sender, address(this)) >= token);
            addressStable.transferFrom(msg.sender, address(this), token);
        } else {
            require(addressUSD.allowance(msg.sender, address(this)) >= usd);
            addressUSD.transferFrom(msg.sender, address(this), usd);
        }


        uint to_return = swapAMM(usd, token);

        if (usd == 0) {
            balanceUSD -= to_return;
            balanceStable += token;

            addressUSD.transfer(msg.sender, to_return);
        } else {
            balanceStable -= to_return;
            balanceUSD += usd;

            addressStable.transfer(msg.sender, to_return);
        }

        // live balancing paying off

        treasuryToBalance();
        extraUsd();
        payDebt();

        return true;
    }

   
}

