//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import { DataTypes } from "../types/DataTypes.sol";
import { ColorGen } from "../utils/ColorGen.sol";
import { PRNG } from "../utils/PRNG.sol";

library AttributesGen {
	function generateAttributes(
		mapping(uint256 => DataTypes.Space) storage s_attributes,
		uint256 tokenId,
		string calldata _text
	) internal {
		DataTypes.Space memory space;
		string[] memory colors = new string[](10); // Declare as dynamic array

		// generate random cloud and button color
		for (uint256 i = 0; i < 10; i++) {
			colors[i] = ColorGen.RGB(bytes32(i));
		}

		space = DataTypes.Space({
			wholeSkyColor: colors[0],
			wholeRiverColor: colors[1],
			mountainDarkColor: colors[2],
			mountainLightColor: colors[3],
			mountainGreyColor: colors[4],
			riverColor3: colors[5],
			riverColor1: colors[6],
			riverColor2: colors[7],
			mainRiverColor: colors[8],
			mountainMediumColor: colors[9],
			text: _text
		});

		s_attributes[tokenId] = space;
	}
}
