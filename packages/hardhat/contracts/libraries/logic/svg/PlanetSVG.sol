// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Strings } from "../../../dependencies/Strings.sol";
import { Base64 } from "base64-sol/base64.sol";

import { DataTypes } from "../../types/DataTypes.sol";
import { TokenURIGen } from "../../utils/TokenURIGen.sol";
import { TypeCast } from "../../utils/TypeCast.sol";

library PlanetSVG {
	using Strings for uint256;

	function tokenURI(
		DataTypes.Planet calldata planet,
		uint256 tokenId
	) external pure returns (string memory) {
		string memory name = string(
			abi.encodePacked("Planet#", tokenId.toString())
		);
		string memory description = string(
			abi.encodePacked("This is a planet")
		);
		string memory image = Base64.encode(bytes(generateSVG(planet)));

		return TokenURIGen.generateSVGTokenURI(name, description, image);
	}

	function renderTokenById(
		DataTypes.Planet calldata planet
	) public pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					'<g id="yellow_moon" data-name="yellow moon" style="transform-origin: 366.531px 136.376px;"transform="matrix(1, 0, 0, 1, 99.753441, 26.158756)">',
					'<title>planet</title><path d="M349.22459,136.51119a15.0625,15.0625,0,1,0,15.0635-15.06348A15.06345,15.06345,0,0,0,349.22459,136.51119Z" style="fill: ',
					planet.halfColor,
					';"><title>half</title></path><path d="M379.34959,136.51119a14.9622,14.9622,0,0,1-17.1074,14.90871,18.58062,18.58062,0,0,1,.9219-29.91506c.372-.02783.7441-.05713,1.124-.05713A15.063,15.063,0,0,1,379.34959,136.51119Z" style="fill: ',
					planet.mainColor,
					';"><title>full</title></path></g>'
				)
			);
	}

	function generateSVG(
		DataTypes.Planet calldata scarf
	) internal pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					'<svg width="100%" height="100%" viewBox="0 0 1453 1274" fill="none" xmlns="http://www.w3.org/2000/svg">',
					renderTokenById(scarf),
					"</svg>"
				)
			);
	}
}
