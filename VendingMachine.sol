// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract VendingMachine {

    // Set vending machine owner
    address owner;

    constructor(){
        owner = msg.sender;
        addProduct("Beer",1000000000000000, 24, 24);
        addProduct("Coke",500000000000000, 12, 12);
    }
    
    // Balance of Vending Machine
    function balanceOf() view public returns(uint) {
        return address(this).balance;
    }

    // Struct Product
    struct Product {
        string name;
        uint price;
        uint maxStock;
        uint currentStock;
    }

    struct BoughtProduct {
        string name;
        uint amount;
    }

    struct Buyer {
        address walletAddress;
        mapping(string => BoughtProduct) boughtProducts;
    }

    mapping(string => Product) public products;
    mapping(address => Buyer) buyers;

    function addProduct(string memory name, uint price, uint maxStock, uint currentStock) public {
        require(msg.sender == owner, "Only the owner can addProduct.");
        require(maxStock >= currentStock, "Current stock can't be more than max stock!");
        require(products[name].maxStock == 0, "Product already exists");
        
        products[name] = Product(name, price, maxStock, currentStock);
       
    }

    function restock(string memory name) public {
        require(msg.sender == owner, "Only the owner can restock.");
        products[name].currentStock = products[name].maxStock;
    }

    function purchase(string memory name, uint amount) public payable {
        require(msg.value >= products[name].price * amount, "You didn't put enough money in the vending machine to purchase this product");
        require(products[name].currentStock >= amount, "There isn't enough stock of this product to fullfill your purchase");

        products[name].currentStock -= amount;

        Buyer storage b = buyers[msg.sender];

        if (b.boughtProducts[name].amount > 0) {
            b.boughtProducts[name].amount += amount;
        } else {
            b.boughtProducts[name] = BoughtProduct(name, amount);
        }
    }

    function balanceOfBuyerByProductName(address walletAddress, string memory name) view public returns(uint){
        return buyers[walletAddress].boughtProducts[name].amount;
    }
}
