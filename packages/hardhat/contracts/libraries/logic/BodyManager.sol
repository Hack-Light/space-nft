//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import { DataTypes } from "../types/DataTypes.sol";

import { ISpace } from "../../interfaces/ISpace.sol";
import { Errors } from "../../interfaces/Errors.sol";

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

library BodyManager {
	event BodyAdded(address body);
	event BodyRemoved(address body, uint256 spaceId);

	function addBody(
		mapping(address => bool) storage s_bodiesAvailable,
		address[] storage s_bodies,
		address body
	) internal {
		if (s_bodiesAvailable[body]) revert Errors.Space__BodyAlreadyExists();

		s_bodiesAvailable[body] = true;
		s_bodies.push(address(body));

		emit BodyAdded(body);
	}

	function removeBody(
		mapping(address => bool) storage s_bodiesAvailable,
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		address body,
		uint256 spaceId
	) internal {
		if (ISpace(address(this)).ownerOf(spaceId) != msg.sender)
			revert Errors.Space__NotOwner();
		if (!hasBody(s_bodiesAvailable, s_bodiesById, body, spaceId))
			revert Errors.Space__BodyNotUsed();

		_removeBody(s_bodiesById, body, spaceId);

		emit BodyRemoved(body, spaceId);
	}

	function _removeBody(
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		address body,
		uint256 spaceId
	) internal {
		Body(body).transferFrom(
			address(this),
			ISpace(address(this)).ownerOf(spaceId),
			s_bodiesById[body][spaceId]
		);

		s_bodiesById[body][spaceId] = 0;
	}

	function hasBody(
		mapping(address => bool) storage s_bodiesAvailable,
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		address body,
		uint256 spaceId
	) internal view returns (bool) {
		if (!s_bodiesAvailable[body]) revert Errors.Space__BodyUnavailable();

		return (s_bodiesById[body][spaceId] != 0);
	}

	function bodyId(
		mapping(address => bool) storage s_bodiesAvailable,
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		address body,
		uint256 spaceId
	) internal view returns (uint256) {
		if (!s_bodiesAvailable[body]) revert Errors.Space__BodyUnavailable();

		return s_bodiesById[body][spaceId];
	}
}
