const {
  time,
  expectRevert,
  expectEvent,
} = require('@openzeppelin/test-helpers')
const { expectPass, from } = require('../helpers')

const TimeLock = artifacts.require('TimeLockMock')

contract('TimeLock', ([alice]) => {
  const defaultDuration = time.duration.days(3)
  let contract

  beforeEach(async () => {
    contract = await TimeLock.new()
  })

  it('has a duration', async () => {
    const duration = await contract.duration()
    expect(duration.toNumber()).to.equal(defaultDuration.toNumber())
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
    await expectRevert(
      contract.timeLockedAction(from(alice)),
      'TimeLock: Account under timelock'
    )
  })

  it('should allow user to recall function after enough time has passed', async () => {
    await contract.timeLockedAction(from(alice))
    await time.increase(time.duration.days(4))
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
  })

  context('release time', async () => {
    it('should return time before unlocking', async () => {
      await contract.timeLockedAction(from(alice))
      await time.increase(time.duration.days(2))
      const releaseTime = (await contract.releaseTime(alice)).toNumber()
      expect(releaseTime).to.be.closeTo(time.duration.days(1).toNumber(), 3)
    })

    it('should return 0 if user has never been locked', async () => {
      const releaseTime = (await contract.releaseTime(alice)).toNumber()
      expect(releaseTime).to.eq(0)
    })

    it('should return 0 if user has been unlocked', async () => {
      await contract.timeLockedAction(from(alice))
      await time.increase(time.duration.days(4))
      const releaseTime = (await contract.releaseTime(alice)).toNumber()

      expect(releaseTime).to.eq(0)
    })
  })

  it('should clear user time lock', async () => {
    await contract.timeLockedAction(from(alice))
    await contract.clearUserTimeLock(alice)
    const isLocked = await contract.isLocked(alice)

    expect(isLocked).to.be.false
  })
})
