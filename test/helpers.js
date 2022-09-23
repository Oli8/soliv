function expectPass(tx) {
  expect(tx.receipt.status).to.be.true
}

function from(address) {
  return { from: address }
}

module.exports = {
  expectPass,
  from,
}
