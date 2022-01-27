const StableAMM = artifacts.require("StableAMM");
const USD = artifacts.require("USD");
const StableToken = artifacts.require("StableToken");

const creator = "0x40c0B3f63459c4301338DFCf7899a0Ec93481f02";

const fs = require('fs');


async function saveLog(amm){

    let usd_balance = await amm.balanceUSD();
    let tok_balance = await amm.balanceStable();
    let treasury = await amm.treasuryUSD();

    let data = '\n'+usd_balance+'\t'+tok_balance+'\t'+treasury;
    console.log(data);
    
    fs.appendFileSync('exp1.txt', data)

}

module.exports = async function(deployer) {
	
    await deployer.deploy(USD);
	const actualUSD = await USD.deployed();
    
    await deployer.deploy(StableToken);
	const actualStableToken = await StableToken.deployed();

  	await deployer.deploy(StableAMM, actualUSD.address, actualStableToken.address);
	const actualAMM = await StableAMM.deployed();

    await actualUSD.transfer(actualAMM.address, '100000000000000000000000000');
    await actualStableToken.transfer(actualAMM.address, '100000000000000000000000000');

    fs.appendFileSync('exp1.txt', 'Amm: '+actualAMM.address+'\n usd: '+actualUSD.address + '\nstabletoken: '+actualStableToken.address);

    await saveLog(actualAMM);
    
    let quantity = '100000000000000000000000';

    await actualUSD.approve(actualAMM.address, '10000000000000000000000000000');
    await actualStableToken.approve(actualAMM.address, '10000000000000000000000000000');

    let counter = 0;

    function sleep(ms){
        return new Promise(r => setTimeout(r, ms));
    }

    

    for(let i=0; counter<0; i++){
        try{
            await actualAMM.swap(quantity, 0);
            await saveLog(actualAMM);
            counter++;
            console.log(counter);
            await sleep(5000);
        } catch (error){} 
        
    }
    

};
