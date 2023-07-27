const {
  time,
  expectRevert,
  expectEvent,
} = require('@openzeppelin/test-helpers')
const { expectRevertCustomError } = require('custom-error-test-helper')
const { expectPass, from } = require('../helpers')

const TimeLockGroups = artifacts.require('TimeLockGroupsMock')

contract('TimeLockGroups', ([alice, bob]) => {
  const gouvernanceLockName = web3.utils.keccak256('GOUVERNANCE')
  const gouvernanceDuration = time.duration.days(3)
  let contract

  beforeEach(async () => {
    contract = await TimeLockGroups.new()
  })

  context('gouvernance lock', async () => {
    it('has a duration', async () => {
      const duration = await contract.duration(gouvernanceLockName)
      expect(duration.toNumber()).to.equal(gouvernanceDuration.toNumber())
    })

    it('should allow user to call time locked function the first time', async () => {
      const action = await contract.createProposal(from(alice))
      expectPass(action)
    })

    context('locking', async () => {
      it("shouldn't lock user before any function call", async () => {
        const isLocked = await contract.isLocked(gouvernanceLockName, alice)
        expect(isLocked).to.be.false
      })

      it('should lock user after function call', async () => {
        await contract.voteBan(from(alice))
        const isLocked = await contract.isLocked(gouvernanceLockName, alice)

        expect(isLocked).to.be.true
      })
    })

    context('recall', async () => {
      it('should prevent user from recalling function too soon', async () => {
        await contract.createProposal(from(alice))
        await expectRevert(
          contract.createProposal(from(alice)),
          'TimeLock: Account under timelock'
        )
      })

      it('should prevent user from recalling function in same lock too soon', async () => {
        await contract.createProposal(from(alice))
        await expectRevert(
          contract.voteBan(from(alice)),
          'TimeLock: Account under timelock'
        )
      })

      it('should allow user to recall function after enough time has passed', async () => {
        await contract.voteBan(from(alice))
        await time.increase(time.duration.days(3))
        const newAction = await contract.voteBan(from(alice))

        expectPass(newAction)
      })

      it('should allow user to recall function in same lock after enough time has passed', async () => {
        await contract.createProposal(from(alice))
        await time.increase(time.duration.days(3))
        const newAction = await contract.voteBan(from(alice))

        expectPass(newAction)
      })
    })

    it('should allow user to call function in another lock after being locked in one', async () => {
      await contract.createProposal(from(alice))
      const newAction = await contract.approve(from(alice))

      expectPass(newAction)
    })

    context('update duration', async () => {
      let newDurationBN, newDuration, durationChange
      beforeEach(async () => {
        newDurationBN = time.duration.days(10)
        newDuration = newDurationBN.toNumber()
        durationChange = await contract.setTimeLockDuration(
          gouvernanceLockName,
          newDuration
        )
      })

      it('should be possible to update duration', async () => {
        const durationFetched = (await contract.duration(gouvernanceLockName)).toNumber()
        expect(durationFetched).to.equal(newDuration)
      })

      it('should emit event on duration change', async () => {
        expectEvent(
          durationChange,
          'DurationChanged',
          {
            name: gouvernanceLockName,
            previousDuration: gouvernanceDuration,
            newDuration: newDurationBN,
          }
        )
      })

      it('should update time needed to recall function', async () => {
        await contract.voteBan(from(alice))
        await time.increase(time.duration.days(4))

        await expectRevert(
          contract.createProposal(from(alice)),
          'TimeLock: Account under timelock'
        )
      })

      it('should allow user to recall function after the new duration has passed', async () => {
        await contract.createProposal(from(alice))
        await time.increase(time.duration.days(10))
        const newAction = await contract.voteBan(from(alice))

        expectPass(newAction)
      })
    })

    context('lock time remaining', async () => {
      it('should return time before unlocking', async () => {
        await contract.voteBan(from(alice))
        await time.increase(time.duration.days(2))
        const releaseTime = (await contract.lockTimeRemaining(
          gouvernanceLockName,
          alice
        )).toNumber()

        expect(releaseTime).to.be.closeTo(time.duration.days(1).toNumber(), 10)
      })

      it('should return 0 if user has never been locked', async () => {
        const releaseTime = (await contract.lockTimeRemaining(
          gouvernanceLockName,
          alice
        )).toNumber()

        expect(releaseTime).to.eq(0)
      })

      it('should return 0 if user has been unlocked', async () => {
        await contract.voteBan(from(alice))
        await time.increase(time.duration.days(4))
        const releaseTime = (await contract.lockTimeRemaining(
          gouvernanceLockName,
          alice
        )).toNumber()

        expect(releaseTime).to.eq(0)
      })
    })

    context('lock function', async () => {
      beforeEach(async () => {
        await contract.lockUser(gouvernanceLockName, bob)
      })

      it('should lock user', async () => {
        const isLocked = await contract.isLocked(gouvernanceLockName, bob)
        expect(isLocked).to.be.true
      })

      it('should prevent user form performing time locked action', async () => {
        await expectRevert(
          contract.voteBan(from(bob)),
          'TimeLock: Account under timelock'
        )
      })
    })

    it('should clear user time lock', async () => {
      await contract.voteBan(from(alice))
      await contract.clearUserTimeLock(gouvernanceLockName, alice)
      const isLocked = await contract.isLocked(gouvernanceLockName, alice)

      expect(isLocked).to.be.false
    })
  })

  context('unset lock duration', async () => {
    let action
    beforeEach(async () => {
      action = await contract.action(from(alice))
    })

    it('should allow user to call function', async () => {
      expectPass(action)
    })

    it('should allow user to recall function', async () => {
      const newAction = await contract.action(from(alice))
      expectPass(newAction)
    })
  })
})
