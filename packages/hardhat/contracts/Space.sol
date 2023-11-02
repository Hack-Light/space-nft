//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// import "hardhat/console.sol";

/* Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)*/
import { ISpace } from "./interfaces/ISpace.sol";
import { IERC721Receiver } from "./interfaces/IERC721Receiver.sol";
import { Errors } from "./interfaces/Errors.sol";

import { ERC721Enumerable, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";

import { DataTypes } from "./libraries/types/DataTypes.sol";
import { SpaceSVG } from "./libraries/logic/svg/SpaceSVG.sol";
import { TypeCast } from "./libraries/utils/TypeCast.sol";
import { ColorGen } from "./libraries/utils/ColorGen.sol";
import { PRNG } from "./libraries/utils/PRNG.sol";
import { BodyManager } from "./libraries/logic/BodyManager.sol";
import { AttributesGen } from "./libraries/logic/AttributesGen.sol";

abstract contract Body {
	function renderTokenById(
		uint256 id
	) external view virtual returns (string memory);

	function transferFrom(
		address from,
		address to,
		uint256 id
	) external virtual;
}

contract Space is ISpace, IERC721Receiver, ERC721Enumerable, Ownable, Errors {
	using TypeCast for bytes;
	using Counters for Counters.Counter;

	event FeeCollectorChanged(address oldFeeCollector, address newFeeCollector);

	uint256 constant MINT_FEE = 0.02 ether;
	address payable s_feeCollector;
	Counters.Counter private s_tokenIds;

	address[] private s_bodies;

	mapping(address body => bool isAvailable) private s_bodiesAvailable;

	mapping(address body => mapping(uint256 spaceId => uint256 bodyId))
		private s_bodiesById;

	mapping(uint256 spaceId => DataTypes.Space space) private s_attributes;

	constructor(address feeCollector) ERC721("Space", "Space") {
		s_feeCollector = payable(feeCollector);
		// console.log(s_feeCollector);
	}

	function mint() public payable returns (uint256) {
		if (msg.value != MINT_FEE) revert Errors.Space__InvalidMintFee();

		s_tokenIds.increment();

		uint256 tokenId = s_tokenIds.current();
		_mint(msg.sender, tokenId);

		// console.log(msg.sender, tokenId);

		AttributesGen.generateAttributes(s_attributes, tokenId);

		return tokenId;
	}

	function addSpaceBody(address body) public onlyOwner {
		BodyManager.addBody(s_bodiesAvailable, s_bodies, body);
	}

	function removeSpaceBody(address body, uint256 spaceId) public {
		BodyManager.removeBody(s_bodiesAvailable, s_bodiesById, body, spaceId);
	}

	function onERC721Received(
		address operator,
		address from,
		uint256 tokenId,
		bytes calldata spaceIdData
	) external returns (bytes4) {
		uint256 spaceId = spaceIdData.toUint256();

		if (ownerOf(spaceId) != from) revert Errors.Space__NotBodyOwner();
		if (s_bodiesAvailable[msg.sender] == false)
			revert Errors.Space__CannotHaveBody();
		if (s_bodiesById[msg.sender][spaceId] > 0)
			revert Errors.Space__BodyAlreadyAdded();

		s_bodiesById[msg.sender][spaceId] = tokenId;

		return this.onERC721Received.selector;
	}

	function hasSpaceBody(
		address body,
		uint256 spaceId
	) public view returns (bool) {
		return
			BodyManager.hasBody(s_bodiesAvailable, s_bodiesById, body, spaceId);
	}

	function spaceBodyId(
		address body,
		uint256 spaceId
	) external view returns (uint256) {
		return
			BodyManager.bodyId(s_bodiesAvailable, s_bodiesById, body, spaceId);
	}

	function getFeeCollector() public view returns (address) {
		return s_feeCollector;
	}

	function getBodies() public view returns (address[] memory) {
		return s_bodies;
	}

	function getBodyById(
		address body,
		uint256 spaceId
	) public view returns (uint256) {
		return s_bodiesById[body][spaceId];
	}

	function isSpaceBodyAvailable(address body) public view returns (bool) {
		return s_bodiesAvailable[body];
	}

	// comment this out

	// function tokenURI(
	// 	uint256 tokenId
	// ) public view override(ERC721, ISpace) returns (string memory) {
	// 	if (!_exists(tokenId)) revert Errors.Space__NotMinted();

	// 	return
	// 		SpaceSVG.tokenURI(
	// 			s_bodies,
	// 			s_bodiesById,
	// 			s_attributes[tokenId],
	// 			tokenId
	// 		);
	// }

	// comment this out

	function renderTokenById(
		uint256 tokenId
	) external view returns (string memory) {
		DataTypes.Space memory space = s_attributes[tokenId];

		return SpaceSVG.renderTokenById(s_bodies, s_bodiesById, space, tokenId);
	}

	receive() external payable {}

	function withdrawFees() external override {}

	function tokenURI(
		uint256 tokenId
	) public view override(ERC721, ISpace) returns (string memory) {}

	// function renderTokenById(
	// 	uint256 tokenId
	// ) external view override returns (string memory) {}
}
