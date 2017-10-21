# DASP Registry
An Ethereum smart contract that acts as a registry for all DASPs, and as a DASP
discovery portal. Anyone can register their DASP here, provided that they offer
a deposit (planned amount is 10 finney). When you remove your DASP from the
registry, your deposit will be refunded, minus 1% reserved for transaction fee.

Since all of a DASP's metadata is stored in its main contract, registering a
DASP is as simple as submitting the main contract's address to the registry.
ENS names are also supported.
