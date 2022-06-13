const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;
    let token;
    let pool;


    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        token = await DamnValuableToken.deploy();
        pool = await TrusterLenderPool.deploy(token.address);

        await token.transfer( pool.address, TOKENS_IN_POOL);

        expect(
            await token.balanceOf( pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */

        const Attacker = await ethers.getContractFactory('TrusterAttacker', deployer);
        const hacker = await Attacker.deploy();

        await hacker.attack(pool.address, attacker.address);

    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await  token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await  token.balanceOf( pool.address)
        ).to.equal('0');
    });
});

