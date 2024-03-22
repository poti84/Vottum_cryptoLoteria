// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

contract cryptoLoteria {
	address private owner;
	uint256 private currentRound = 0;

	uint256 public ticketCoste = 0.0001 ether;
	mapping(uint256 => uint64) ganadores;

	mapping(uint256 => mapping(address => uint64[])) jugadores;
	mapping(uint256 => mapping(uint64 => address payable[])) tickets;

	constructor() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier unpackCheck(uint64 packed)
	{
		for (uint8 i = 0; i < 5; i++) {
			uint8 number = uint8(packed >> (i * 8)) & 0xff;
			require(number > 0 && number < 40);
		}
		_;
	}

	function cambiarTicketCoste(uint256 value)
		onlyOwner
		public
	{
		ticketCoste = value;
	}

	function buy(address payable _address, uint64 numbers)
		unpackCheck(numbers)
		external
		payable
	{
		require(msg.value >= ticketCoste);
		jugadores[currentRound][_address].push(numbers);
		tickets[currentRound][numbers].push(_address);
	}

	function end(uint64 numbers)
		onlyOwner
		unpackCheck(numbers)
		public
	{
		ganadores[currentRound] = numbers;
		address payable[] memory addresses = tickets[currentRound][numbers];
		uint256 amount = (address(this).balance * 60 / 100) / addresses.length;
		for (uint8 i = 0; i < addresses.length; i++) {
			addresses[i].transfer(amount);
		}
		currentRound++;
	}

	function getTickets(address _address)
		public
		view
		returns (uint64[] memory)
	{
		return jugadores[currentRound][_address];
	}

	function getBalance()
		public
		view
		returns (uint256)
	{
		return address(this).balance;
	}

	function getTicektsCoste()
		public
		view
		returns (uint256)
	{
		return ticketCoste;
	}

	function lastWinners()
		public
		view
		returns (uint64)
	{
		require(currentRound > 0);
		return ganadores[currentRound - 1];
	}
}
