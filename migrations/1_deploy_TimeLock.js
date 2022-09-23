const PPS = artifacts.require("TimeLockMock")

module.exports = function (deployer, network, [alice]) {
  if (network === 'development') {
    return deployer.deploy(
      PPS,
      { from: alice }
    )
  }

  return deployer.deploy(PPS)
}
