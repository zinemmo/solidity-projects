// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

import "./DateTime/DateTime.sol";

// As the salary is based on USD we could use an Blockchain Oracle to retrieve the value pair of ETH/USD on the day to calculate the amount to send
// However as we´re developing a Front-End and Back-End we can call API's from there and pass by argument reducing the amount of gas used

contract WageAdministration {
    address private owner;
    uint public contractBalance;
    uint private index = 0;
    uint weiUSD;
    
    enum paymentTypes { Monthly, BiWeekly, Weekly, Daily, Terminated }
    
    DateTime d = new DateTime();
    
    // Salary will always have 2 digits for decimals 10k should be representend as 1000000
    struct Employee {
        address employeeAddress;
        uint salary;
        uint index;
        paymentTypes paymentType;
        uint paymentTime;
        string role;
        bool exists;
        // all past payments
        Payment[] payments;
    }
    
    // The payment (salary) struct
    struct Payment {
        uint amount;
        uint timestamp;
    }
    
    // mapping(address => string) private paymentPeriod;
    // mapping with all employees
    mapping(address => Employee) public employees;
    Employee[] private employeesArray;
    
    // set the owner of the contract
    constructor() {
        owner = msg.sender;
    }
    
    /*
       Modifiers
    */
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can use this function");
        _;
    }
    
    modifier onlyEmployee() {
        require(employees[msg.sender].exists == true, "You're not an employee on this company");
        _;
    }
    
    function ceil(uint a, uint m) private pure returns (uint ) {
        return ((a + m - 1) / m) * m;
    }
    
    // Employee Creation
    function addEmployee(address _employee, string calldata _role, uint _salary, uint8 _paymentType) public onlyOwner {
        require(employees[_employee].exists == false, "There already exists an employee with this address");
        
        employees[_employee].employeeAddress = _employee;
        employees[_employee].salary = _salary;
        employees[_employee].role = _role;
        employees[_employee].paymentType = paymentTypes(_paymentType);
        employees[_employee].paymentTime = block.timestamp;
        employees[_employee].index = index;
        employees[_employee].exists = true;
        
        index++;
        
        employeesArray.push(employees[_employee]);
    }
    
    function removeEmployee(address _employee) public onlyOwner {
        require(employees[_employee].exists == true, "This employee does not exist");
        
        employees[_employee].employeeAddress = _employee;
        employees[_employee].salary = 0;
        employees[_employee].role = "Terminated";
        employees[_employee].paymentType = paymentTypes(4);
        employees[_employee].paymentTime = block.timestamp;
        
        employees[_employee].exists = false;
        
        // Remove from employeesArray
        if(employeesArray.length == 1) {
            employeesArray.pop();
        } else {
            employeesArray[employees[_employee].index] = employeesArray[employeesArray.length - 1];
            employees[employeesArray[employeesArray.length - 1].employeeAddress].index = employees[_employee].index;
            employeesArray.pop();
        }
    }
    
    // Payment Operations
    function payMonthlySalary(address _toEmployee) private {
        uint valueToSendInWei = (employees[_toEmployee].salary*weiUSD)/100;
        payable(_toEmployee).transfer(valueToSendInWei);
        employees[_toEmployee].payments.push(Payment(
            valueToSendInWei,
            block.timestamp
        ));
    }
    
    function payBiWeeklySalary(address _toEmployee) private {
        uint valueToSendInWei = (employees[_toEmployee].salary*weiUSD)/200;
        payable(_toEmployee).transfer(valueToSendInWei);
        employees[_toEmployee].payments.push(Payment(
            valueToSendInWei,
            block.timestamp
        ));
    }
    
    function payWeeklySalary(address _toEmployee) private {
        uint valueToSendInWei = (employees[_toEmployee].salary*weiUSD)/400;
        payable(_toEmployee).transfer(valueToSendInWei);
        employees[_toEmployee].payments.push(Payment(
            valueToSendInWei,
            block.timestamp
        ));
    }
    
    function payDailySalary(address _toEmployee, uint _timestamp) private {
        uint valueToSendInWei = (employees[_toEmployee].salary*weiUSD)/
        (d.getDaysInMonth(d.getMonth(_timestamp), d.getYear(_timestamp))*100);
        
        payable(_toEmployee).transfer(valueToSendInWei);
        employees[_toEmployee].payments.push(Payment(
            valueToSendInWei,
            _timestamp
        ));
    }
    
    function payEmployeesSalaries(address[] calldata _employees, uint _weiUSD) public onlyOwner {
        // Receive an array of employees available to receive their salary
        uint totalBalanceRequired;
        weiUSD = _weiUSD;
        uint j;
        
        // Iterate through them and calculate the amount of balance needed for this contract (salary + gas)
        if(_employees.length == 1) {
            totalBalanceRequired += employees[_employees[0]].salary;
        } else {
            for (j = 0; j < _employees.length; j++) {
                totalBalanceRequired += employees[_employees[j]].salary;
            }
        }
        
        // _weiUSD is the amount of wei for each USD
        totalBalanceRequired = (totalBalanceRequired * weiUSD)/100;
        
        totalBalanceRequired += tx.gasprice * _employees.length;
        
        require(address(this).balance > totalBalanceRequired, "This contract needs more funds to complete the transactions");
        
        // The lack of switch statement makes me sad here
        for (j = 0; j < _employees.length; j++) {
            if(employees[_employees[j]].paymentType == paymentTypes(0)) {
                payMonthlySalary(_employees[j]);
            } else if (employees[_employees[j]].paymentType == paymentTypes(1)) {
                payBiWeeklySalary(_employees[j]);
            } else if (employees[_employees[j]].paymentType == paymentTypes(2)) {
                payWeeklySalary(_employees[j]);
            } else if (employees[_employees[j]].paymentType == paymentTypes(3)) {
                payDailySalary(_employees[j], block.timestamp);
            } else {
                revert("This payment type is not supported");
            }
        }
    }
    
    function setPaymentPeriod(uint8 _newPaymentType) public onlyEmployee {
        if(_newPaymentType <= 3) {
            employees[msg.sender].paymentType = paymentTypes(_newPaymentType);
        } else {
            revert("This payment type is not supported");
        }
    }
    
    // Return the balance of the current user
    function getOwnEmployeeData() public view onlyEmployee returns(address, paymentTypes, uint, string memory) {
        return (employees[msg.sender].employeeAddress, employees[msg.sender].paymentType, employees[msg.sender].salary, employees[msg.sender].role);
    }
    
    /*
       Contract funds operations
    */
    
    // Add funds to own contract
    function addContractBalance() public payable onlyOwner {}
    
    // Returns the contract balance
    function getContractBalance() public view onlyOwner returns(uint)  {
        return address(this).balance;
    }
    
}
