// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28; // This is the version used

contract Storage {
    // favorite number gets initialized to 0 if no value is assigned
    uint256 public favoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
        retrieve();
    }

    // uint[] listOfFavoriteNumbers;
    // Creating a Person struct
    struct Person {
        uint256 favNumber;
        string name;
    }

    // This is what we call a dynamic array
    Person[] public listOfPeople;

    // This is what we call a mapping. Here we are mapping a name to a favorite Number
    mapping(string => uint256) public nameToFavNumber;

    function addPersonToList (uint256 _favNumber, string memory _name) public {
        Person memory newPerson = Person({favNumber: _favNumber, name: _name});
        listOfPeople.push(newPerson);
        nameToFavNumber[_name] = _favNumber;
    }

    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }
}
