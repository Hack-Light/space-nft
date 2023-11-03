//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import { DataTypes } from "../libraries/types/DataTypes.sol";
import { IERC721Enumerable } from "@openzeppelin/contracts/interfaces/IERC721Enumerable.sol";

interface ISpace is IERC721Enumerable {
	event SpaceBodyAdded(address body);
	event SpaceBodyRemoved(address body);

	function mint(string calldata text) external payable returns (uint256);

	function addSpaceBody(address body) external;

	function removeSpaceBody(address body, uint256 spaceId) external;

	function withdrawFees() external;

	function hasSpaceBody(
		address body,
		uint256 spaceId
	) external view returns (bool);

	function spaceBodyId(
		address body,
		uint256 spaceId
	) external view returns (uint256);

	function tokenURI(uint256 tokenId) external view returns (string memory);

	function renderTokenById(
		uint256 tokenId
	) external view returns (string memory);

	function isSpaceBodyAvailable(address body) external view returns (bool);

	function getFeeCollector() external view returns (address);

}
