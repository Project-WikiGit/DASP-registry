/*
    dasp_registry.sol
    Created by Zefram Lou (Zebang Liu) as part of the WikiGit project.

    This file implements a smart contract that acts as a registry for all DASPs, and
    as a DASP discovery portal.
*/

pragma solidity ^0.4.11;

contract DASPRegistry {
    struct Entry {
        address addr;
        string ENSName;
        address owner;
    }

    modifier onlyMaster { require(msg.sender == regMaster); _; }

    Entry[] DASPEntryList;
    uint numOfEntries;
    mapping(address => uint) depositForAddressInFinneys;
    bytes32 emptyStrHash;
    address regMaster; //Master of the registry. Can withdraw leftover funds.
    uint depositAmountInFinneys; //The amount one must deposit when adding an entry.

    //Constructor
    function DASPRegistry(uint depositInFinneys) public {
        depositAmountInFinneys = depositInFinneys;
        emptyStrHash = keccak256('');
        regMaster = msg.sender;
    }

    //Mutators

    /*
        Registers a DASP. Should only input one of the first
        two arguments.
    */
    function addDASPEntry(
        address addr,
        string ENSName,
        address owner
    )
        payable
        public
    {
        bytes32 ENSNameHash = keccak256(ENSName);

        //Must pay deposit
        require(msg.value == depositAmountInFinneys * 1 finney);
        //Needs the user to input only one of the two arguments
        require(xor(addr != 0x0, stringNotEmpty(ENSNameHash)));

        DASPEntryList.push(Entry({
            addr: addr,
            ENSName: ENSName,
            owner: owner
        }));
        numOfEntries += 1;

        depositForAddressInFinneys[owner] += depositAmountInFinneys * 1 finney;
    }

    function removeDASPEntryAtIndex(uint index) public {
        Entry storage entry = DASPEntryList[index];
        require(entry.owner == msg.sender);
        require(depositForAddressInFinneys[msg.sender] > 0);

        delete DASPEntryList[index];
        numOfEntries -= 1;

        //Refund deposit. 1% is reserved for transaction fee
        depositForAddressInFinneys[msg.sender] -= depositAmountInFinneys * 1 finney;
        msg.sender.transfer(depositAmountInFinneys * 0.99 finney);
    }

    //Getters

    function DASPAddrAtIndex(uint index) view public returns(address) {
        Entry storage entry = DASPEntryList[index];
        return entry.addr;
    }

    function DASPENSNameAtIndex(uint index) view public returns(string) {
        Entry storage entry = DASPEntryList[index];
        return entry.ENSName;
    }

    function ownerAtIndex(uint index) view public returns(address) {
        Entry storage entry = DASPEntryList[index];
        return entry.owner;
    }

    function amountOfExtraFundsInWeis() view public returns(uint) {
        //amount = balance - withdrawn - deposits
        //Can be non-zero since 1% of deposit that's
        //reserved for transaction fee might not all be spent.
        uint amount = this.balance
            - (DASPEntryList.length - numOfEntries) * depositAmountInFinneys * 0.99 finney
            - numOfEntries * depositAmountInFinneys * 1 finney;
        return amount;
    }

    //Withdraw leftover funds

    function withdrawExtraFunds(address beneficiary) public onlyMaster {
        uint amount = amountOfExtraFundsInWeis();
        //Prevent overflow
        require(beneficiary.balance + amount >= beneficiary.balance);
        //Transfer
        beneficiary.transfer(amount);
    }

    //Helper functions

    function stringNotEmpty(bytes32 strHash) view internal returns(bool) {
        return strHash != emptyStrHash;
    }

    function xor(bool a, bool b) pure internal returns(bool) {
        return (a && !b) || (!a && b);
    }

    function(){
        revert();
    }
}
