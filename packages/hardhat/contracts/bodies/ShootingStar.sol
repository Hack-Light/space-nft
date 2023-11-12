/// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { ERC721Enumerable, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

import { DataTypes } from "../libraries/types/DataTypes.sol";
import { ShootingStarSVG } from "../libraries/logic/svg/ShootingStarSVG.sol";
import { TypeCast } from "../libraries/utils/TypeCast.sol";
import { PRNG } from "../libraries/utils/PRNG.sol";

error ShootingStar__NotMinted();
error ShootingStar__InvalidMintFee();
error ShootingStar__TransferFailed();
error ShootingStar__ZeroAddress();
error ShootingStar__InvalidFeeCollector();
error ShootingStar__NotOwner();

contract ShootingStar is ERC721Enumerable, Ownable {
	using TypeCast for bytes;
	using Counters for Counters.Counter;

	event FeeCollectorChanged(address oldFeeCollector, address newFeeCollector);

	uint256 constant MINT_FEE = 0.01 ether;
	address s_feeCollector;
	Counters.Counter private s_tokenIds;

	mapping(uint256 shootingstarId => DataTypes.ShootingStar shootingstar) private s_attributes;

	constructor(address feeCollector) ERC721("ShootingStar", "ShootingStar") {
		s_feeCollector = feeCollector;
	}

	function mint() public payable returns (uint256) {
		if (msg.value < MINT_FEE) revert ShootingStar__InvalidMintFee();

		s_tokenIds.increment();

		uint256 tokenId = s_tokenIds.current();
		_mint(msg.sender, tokenId);

		// generate random color
		s_attributes[tokenId] = DataTypes.ShootingStar({
			duration: PRNG.range(15, 60, keccak256("1"))
		});

		// transfer mint fee
		(bool success, ) = payable(owner()).call{ value: msg.value }("");
		if (!success) revert ShootingStar__TransferFailed();

		return tokenId;
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		if (!_exists(tokenId)) revert ShootingStar__NotMinted();

		DataTypes.ShootingStar memory shootingstar = s_attributes[tokenId];

		return ShootingStarSVG.tokenURI(shootingstar, tokenId);
	}

	function renderTokenById(
		uint256 tokenId
	) public view returns (string memory) {
		DataTypes.ShootingStar memory shootingstar = s_attributes[tokenId];

		return ShootingStarSVG.renderTokenById(shootingstar);
	}

	function setFeeCollector(address newFeeCollector) public onlyOwner {
		address oldFeeCollector = s_feeCollector;
		if (newFeeCollector == address(0)) revert ShootingStar__ZeroAddress();
		if (newFeeCollector == oldFeeCollector)
			revert ShootingStar__InvalidFeeCollector();

		s_feeCollector = newFeeCollector;

		emit FeeCollectorChanged(oldFeeCollector, newFeeCollector);
	}

	function getFeeCollector() public view returns (address) {
		return s_feeCollector;
	}

	function getAttributes(
		uint256 tokenId
	) public view returns (DataTypes.ShootingStar memory) {
		return s_attributes[tokenId];
	}
}
