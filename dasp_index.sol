/*
    dasp_index.sol
    Created by Zefram Lou (Zebang Liu) as part of the WikiGit project.

    This file implements a smart contract that indexes all DASPs, and
    will act as a discovery portal for DASPs.
*/

pragma solidity ^0.4.11;

contract DASPIndex {
    struct Entry {
        address addr;
        string ENSName;
        address owner;
    }

    Entry[] DASPEntryList;
    mapping(address => uint) depositInWeis;
    bytes32 emptyStrHash;

    function DASPIndex() public {
        emptyStrHash = keccak256('');
    }

    function addDASPEntry(
        address addr,
        string ENSName,
        address owner
    )
        payable
        public
    {
        bytes32 ENSNameHash = keccak256(ENSName);

        //Must pay 0.01 ether as deposit
        require(msg.value == 0.01 ether);
        require(xor(addr != 0x0, stringNotEmpty(ENSNameHash)));

        DASPEntryList.push(Entry({
            addr: addr,
            ENSName: ENSName,
            owner: owner
        }));

        depositInWeis[owner] += 0.01 ether;
    }

    function removeDASPEntryAtIndex(uint index) public {
        Entry storage entry = DASPEntryList[index];
        require(entry.owner == msg.sender);
        require(depositInWeis[msg.sender] > 0);

        delete DASPEntryList[index];

        //Refund deposit. 0.5% is used for transaction fee
        depositInWeis[msg.sender] -= 0.01 ether;
        msg.sender.transfer(0.01 * 0.995 ether);
    }

    function DASPAddrAtIndex(uint index) public returns(address) {
        Entry storage entry = DASPEntryList[index];
        return entry.addr;
    }

    function DASPENSNameAtIndex(uint index) public returns(stirng) {
        Entry storage entry = DASPEntryList[index];
        return entry.ENSName;
    }

    function ownerAtIndex(uint index) public returns(address) {
        Entry storage entry = DASPEntryList[index];
        return entry.owner;
    }

    function stringNotEmpty(bytes32 strHash) view internal returns(bool) {
        return strHash != emptyStrHash;
    }

    function xor(bool a, bool b) pure internal returns(bool) {
        return (a && !b) || (!a && b);
    }
}
