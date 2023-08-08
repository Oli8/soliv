const {
  time,
  expectEvent,
} = require('@openzeppelin/test-helpers')
const { expectRevertCustomError } = require('custom-error-test-helper')
const { expectPass, from } = require('../helpers')

const TimeLock = artifacts.require('TimeLockMock')

contract('TimeLock', ([alice, bob]) => {
  const defaultDuration = time.duration.days(3)
  let contract

  beforeEach(async () => {
    contract = await TimeLock.new()
  })

  it('has a duration', async () => {
    const duration = await contract.duration()
    expect(duration.toNumber()).to.equal(defaultDuration.toNumber())
  })

  it('should allow user to call time locked function the first time', async () => {
    const action = await contract.timeLockedAction(from(alice))
    expectPass(action)
  })

  context('locking', async () => {
    it("shouldn't lock user before any function call", async () => {
      const isLocked = await contract.isLocked(alice)
      expect(isLocked).to.be.false
    })

    it('should lock user after function call', async () => {
      await contract.timeLockedAction(from(alice))
      const isLocked = await contract.isLocked(alice)

      expect(isLocked).to.be.true
    })
  })

  it('should prevent user from recalling function too soon', async () => {
    await contract.timeLockedAction(from(alice))
    await expectRevertCustomError(
      TimeLock,
      contract.timeLockedAction(from(alice)),
      'LockedUser',
      [alice]
    )
  })

  it('should allow user to recall function after enough time has passed', async () => {
    await contract.timeLockedAction(from(alice))
    await time.increase(time.duration.days(3))
    const newAction = await contract.timeLockedAction(from(alice))

    expectPass(newAction)
  })

  context('update duration', async () => {
    let newDurationBN, newDuration, durationChange
    beforeEach(async () => {
      newDurationBN = time.duration.days(10)
      newDuration = newDurationBN.toNumber()
      durationChange = await contract.setTimeLockDuration(newDuration)
    })

    it('should be possible to update duration', async () => {
      const durationFetched = (await contract.duration()).toNumber()
      expect(durationFetched).to.equal(newDuration)
    })

    it('should emit event on duration change', async () => {
      expectEvent(
        durationChange,
        'DurationChanged',
        {
          previousDuration: defaultDuration,
          newDuration: newDurationBN,
        }
      )
    })

    context('recall after duration update', async () => {
      beforeEach(async () => {
        await contract.timeLockedAction(from(alice))
      })

      it('should update time needed to recall function', async () => {
        await time.increase(time.duration.days(4))

        await expectRevertCustomError(
          TimeLock,
          contract.timeLockedAction(from(alice)),
          'LockedUser',
          [alice]
        )
      })

      it('should allow user to recall function after the new duration has passed', async () => {
        await time.increase(time.duration.days(10))
        const newAction = await contract.timeLockedAction(from(alice))

        expectPass(newAction)
      })
    })
  })

  context('lock time remaining', async () => {
    it('should return time before unlocking', async () => {
      await contract.timeLockedAction(from(alice))
      await time.increase(time.duration.days(2))
      const releaseTime = (await contract.lockTimeRemaining(alice)).toNumber()

      expect(releaseTime).to.be.closeTo(time.duration.days(1).toNumber(), 3)
    })

    it('should return 0 if user has never been locked', async () => {
      const releaseTime = (await contract.lockTimeRemaining(alice)).toNumber()
      expect(releaseTime).to.eq(0)
    })

    it('should return 0 if user has been unlocked', async () => {
      await contract.timeLockedAction(from(alice))
      await time.increase(time.duration.days(4))
      const releaseTime = (await contract.lockTimeRemaining(alice)).toNumber()

      expect(releaseTime).to.eq(0)
    })
  })

  context('lock function', async () => {
    let userLocking
    beforeEach(async () => {
      userLocking = await contract.lockUser(bob)
    })

    it('should lock user', async () => {
      const isLocked = await contract.isLocked(bob)
      expect(isLocked).to.be.true
    })

    it('should prevent user form performing time locked action', async () => {
      await expectRevertCustomError(
        TimeLock,
        contract.timeLockedAction(from(bob)),
        'LockedUser',
        [bob]
      )
    })

    it('should emit event on user lock time change', async () => {
      expectEvent(
        userLocking,
        'UserLockTimeChanged',
        { user: bob }
      )
    })
  })

  it('should clear user time lock', async () => {
    await contract.timeLockedAction(from(alice))
    await contract.clearUserTimeLock(alice)
    const isLocked = await contract.isLocked(alice)

    expect(isLocked).to.be.false
  })
})
