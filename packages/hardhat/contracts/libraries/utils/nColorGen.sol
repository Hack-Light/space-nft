//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

import { PRNG } from "./PRNG.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

library ColorGen {
	using PRNG for uint256;
	using Strings for uint256;

	bytes16 internal constant ALPHABET = "0123456789abcdef";
	uint256 internal constant MIN_RGB_VALUE = 0;
	uint256 internal constant MAX_RGB_VALUE = 255;
	uint256 internal constant MIN_HSL_VALUE = 0;
	uint256 internal constant MAX_HSL_VALUE = 100;
	uint256 internal constant MIN_ALPHA = 3;
	uint256 internal constant MAX_ALPHA = 10;
	uint256 internal constant FACTOR = 5;

	function HEX() internal view returns (string memory) {
		bytes32 randHash = keccak256(
			abi.encodePacked(
				blockhash(block.number - 1),
				msg.sender,
				address(this)
			)
		);
		bytes3 color = bytes2(randHash[0]) |
			(bytes2(randHash[1]) >> 8) |
			(bytes3(randHash[2]) >> 16);
		return _formatHEX(color);
	}

	function HEX(bytes32 seed) internal view returns (string memory) {
		bytes32 randHash = keccak256(
			abi.encodePacked(
				seed,
				blockhash(block.number - 1),
				msg.sender,
				address(this)
			)
		);
		bytes3 color = bytes2(randHash[0]) |
			(bytes2(randHash[1]) >> 8) |
			(bytes3(randHash[2]) >> 16);
		return _formatHEX(color);
	}

	function RGB() internal view returns (string memory) {
		uint256[3] memory randNums;

		for (uint256 i = 0; i < 3; i++) {
			randNums[i] = MIN_RGB_VALUE.range(MAX_RGB_VALUE, bytes32(i));
		}

		string memory color = _formatRGB(randNums[0], randNums[1], randNums[2]);
		return color;
	}

	function RGB(bytes32 seed) internal view returns (string memory) {
		uint256[3] memory randNums;

		for (uint256 i = 0; i < 3; i++) {
			bytes32 _seed = bytes32(keccak256(abi.encodePacked(seed, i)));
			randNums[i] = MIN_RGB_VALUE.range(MAX_RGB_VALUE, _seed);
		}

		string memory color = _formatRGB(randNums[0], randNums[1], randNums[2]);
		return color;
	}

	function RGBA() internal view returns (string memory) {
		uint256[4] memory randNums;

		//  rgb
		for (uint256 i = 0; i < 3; i++) {
			randNums[i] = MIN_RGB_VALUE.range(MAX_RGB_VALUE, bytes32(i));
		}
		//  alpha
		randNums[3] = MIN_ALPHA.range(MAX_ALPHA);

		string memory color = _formatRGBA(
			randNums[0],
			randNums[1],
			randNums[2],
			randNums[3]
		);
		return color;
	}

	function RGBA(bytes32 seed) internal view returns (string memory) {
		uint256[4] memory randNums;

		//  rgb
		for (uint256 i = 0; i < 3; i++) {
			bytes32 _seed = bytes32(keccak256(abi.encodePacked(seed, i)));
			randNums[i] = MIN_RGB_VALUE.range(MAX_RGB_VALUE, _seed);
		}
		//  alpha
		randNums[3] = MIN_ALPHA.range(MAX_ALPHA, seed);

		string memory color = _formatRGBA(
			randNums[0],
			randNums[1],
			randNums[2],
			randNums[3]
		);
		return color;
	}

	function HSL() internal view returns (string memory) {
		uint256[3] memory randNums;

		for (uint256 i = 0; i < 3; i++) {
			randNums[i] = MIN_HSL_VALUE.range(MAX_HSL_VALUE, bytes32(i));
		}

		string memory color = _formatHSL(randNums[0], randNums[1], randNums[2]);
		return color;
	}

	function HSL(bytes32 seed) internal view returns (string memory) {
		uint256[3] memory randNums;

		for (uint256 i = 0; i < 3; i++) {
			bytes32 _seed = bytes32(keccak256(abi.encodePacked(seed, i)));
			randNums[i] = MIN_HSL_VALUE.range(MAX_HSL_VALUE, _seed);
		}

		string memory color = _formatHSL(randNums[0], randNums[1], randNums[2]);
		return color;
	}

	function HSLA() internal view returns (string memory) {
		uint256[4] memory randNums;

		for (uint256 i = 0; i < 3; i++) {
			randNums[i] = MIN_HSL_VALUE.range(MAX_HSL_VALUE, bytes32(i));
		}

		randNums[3] = MIN_ALPHA.range(MAX_ALPHA);

		string memory color = _formatHSLA(
			randNums[0],
			randNums[1],
			randNums[2],
			randNums[3]
		);
		return color;
	}

	function HSLA(bytes32 seed) internal view returns (string memory) {
		uint256[4] memory randNums;

		for (uint256 i = 0; i < 3; i++) {
			bytes32 _seed = bytes32(keccak256(abi.encodePacked(seed, i)));
			randNums[i] = MIN_HSL_VALUE.range(MAX_HSL_VALUE, _seed);
		}

		randNums[3] = MIN_ALPHA.range(MAX_ALPHA, seed);

		string memory color = _formatHSLA(
			randNums[0],
			randNums[1],
			randNums[2],
			randNums[3]
		);
		return color;
	}

	function generateRGBMonochromaticColorCombinations(
		bytes32 seed
	)
		internal
		view
		returns (string memory darkerColor, string memory lighterColor)
	{
		// function generateMonochromaticColorCombinations(bytes32 seed) internal view returns (string memory lighterColor, string memory baseColor, string memory darkerColor) {
		// Generate the base color
		string memory baseColor = RGB(seed);

		// Extract RGB components from the base color
		uint256[3] memory rgbComponents = _extractRGBComponents(baseColor);

		// Adjust brightness for lighter and darker shades
		uint256 lightnessFactor = 100; // You can adjust this factor based on your preference

		// Generate lighter shade
		uint256[3] memory lighterRGB = _adjustBrightness(
			rgbComponents,
			int256(lightnessFactor)
		);
		lighterColor = _formatRGB(lighterRGB[0], lighterRGB[1], lighterRGB[2]);

		// Generate darker shade
		uint256[3] memory darkerRGB = _adjustBrightness(
			rgbComponents,
			-int256(lightnessFactor)
		);
		darkerColor = _formatRGB(darkerRGB[0], darkerRGB[1], darkerRGB[2]);

		console.log(lighterColor, darkerColor, baseColor);

		return (darkerColor, lighterColor);
		// return (lighterColor, baseColor, darkerColor);
	}

	function generateRandomColorScheme()
		internal
		view
		returns (
			string memory baseColor,
			string memory lighterShade,
			string memory complementaryColor
		)
	{
		// Generate a random base color
		baseColor = HEX();

		// Extract RGB components from the base color
		uint256[3] memory rgbComponents = _extractRGBComponents(baseColor);

		// Generate lighter shade
		uint256 lightnessFactor = 20; // You can adjust this factor based on your preference
		uint256[3] memory lighterRGB = _adjustBrightness(
			rgbComponents,
			int256(lightnessFactor)
		);
		lighterShade = _formatRGB(lighterRGB[0], lighterRGB[1], lighterRGB[2]);

		// Generate complementary color
		complementaryColor = _generateComplementaryColor(rgbComponents);

		return (baseColor, lighterShade, complementaryColor);
	}

	function generateComplementaryColorArray(
		uint256 length
	) internal view returns (string[] memory) {
		require(
			length > 0,
			"generateComplementaryColorArray: Length must be greater than 0"
		);

		string[] memory complementaryColors = new string[](length);

		for (uint256 i = 0; i < length; i++) {
			bytes32 seed = keccak256(
				abi.encodePacked(
					blockhash(block.number - 1),
					msg.sender,
					address(this),
					i
				)
			);
			complementaryColors[i] = generateRandomComplementaryColor(seed);
		}

		return complementaryColors;
	}

	function generateRandomComplementaryColor(
		bytes32 seed
	) internal view returns (string memory) {
		// Generate a random base color
		string memory baseColor = HEX(seed);

		// Extract RGB components from the base color
		uint256[3] memory rgbComponents = _extractRGBComponents(baseColor);

		// Generate complementary color
		string memory complementaryColor = _generateComplementaryColor(
			rgbComponents
		);

		return complementaryColor;
	}

	function generateMonochromaticColorCombinations()
		internal
		view
		returns (string memory baseColor, string memory lighterShade)
	{
		// Generate a random base color
		baseColor = HEX();

		// Calculate a lighter shade of the base color
		lighterShade = getLighterShade(baseColor);

		return (baseColor, lighterShade);
	}

	function getLighterShade(
		string memory hexColor
	) internal pure returns (string memory) {
		// Calculate lighter shade
		uint256 newColor = calculateShade(hexColor);

		// Convert uint256 to bytes3
		bytes3 newColorBytes3 = uint256ToBytes3(newColor);

		// Convert bytes3 to hex color string
		return _formatHEX(newColorBytes3);
	}

	function calculateComponentShade(
		uint256 value
	) internal pure returns (uint256) {
		// Use a custom clamp function to ensure the value is within the valid RGB range
		console.log("value", value);
		uint256 newValue = value + ((255 - value) * FACTOR) / 100;

		// Ensure newValue is within the bounds of a uint256
		if (newValue > 255) {
			return 255;
		} else {
			return newValue;
		}
	}

	function calculateShade(
		string memory hexColor
	) internal pure returns (uint256) {
		// Extract RGB components
		uint256 r = _extractComponent(hexColor, 1, 2);
		uint256 g = _extractComponent(hexColor, 3, 2);
		uint256 b = _extractComponent(hexColor, 5, 2);

		console.log("rgb", r, g, b);

		// Calculate lighter shade
		uint256 newR = calculateComponentShade(r);
		uint256 newG = calculateComponentShade(g);
		uint256 newB = calculateComponentShade(b);

		// Convert back to uint256
		return (newR << 16) | (newG << 8) | newB;
	}

	// Utility function to extract a substring from a string
	function substring(
		string memory str,
		uint256 startIndex,
		uint256 length
	) internal pure returns (string memory) {
		bytes memory strBytes = bytes(str);
		console.log("string", str, startIndex, length);

		require(
			startIndex + length <= strBytes.length,
			"substring: Out of bounds"
		);
		bytes memory result = new bytes(length);
		for (uint256 i = 0; i < length; i++) {
			result[i] = strBytes[startIndex + i];
		}
		return string(result);
	}

	function _extractHSLComponents(
		string memory color
	) private pure returns (uint256[3] memory) {
		// Extract HSL components from the color string
		uint256[3] memory hslComponents;
		hslComponents[0] = _extractComponent(color, 4, 3); // Hue
		hslComponents[1] = _extractComponent(color, 10, 2); // Saturation
		hslComponents[2] = _extractComponent(color, 13, 2); // Lightness
		return hslComponents;
	}

	function _extractRGBComponents(
		string memory color
	) private pure returns (uint256[3] memory) {
		// Extract RGB components from the color string
		uint256[3] memory rgbComponents;
		rgbComponents[0] = _extractComponent(color, 4, 3); // Red
		rgbComponents[1] = _extractComponent(color, 9, 3); // Green
		rgbComponents[2] = _extractComponent(color, 14, 3); // Blue
		return rgbComponents;
	}

	function _extractHexComponents(
		string memory color
	) private pure returns (uint256[3] memory) {
		// Extract RGB components from the color string
		uint256[3] memory rgbComponents;
		rgbComponents[0] = _extractComponent(color, 1, 2); // Red
		rgbComponents[1] = _extractComponent(color, 3, 2); // Green
		rgbComponents[2] = _extractComponent(color, 5, 2); // Blue
		console.log(
			"rgbComponents",
			rgbComponents[0],
			rgbComponents[1],
			rgbComponents[2]
		);
		return rgbComponents;
	}

	function _extractComponent(
		string memory color,
		uint256 startIndex,
		uint256 length
	) private pure returns (uint256) {
		// Convert the string to bytes
		bytes memory colorBytes;
		assembly {
			colorBytes := add(color, 0x20)
		}

		// Extract a single component (e.g., R, G, or B) from the color string
		uint256 component = 0;
		for (uint256 i = 0; i < length; i++) {
			uint8 charValue = uint8(colorBytes[startIndex + i]);
			if (charValue >= 48 && charValue <= 57) {
				// Digit 0-9
				charValue -= 48;
			} else if (charValue >= 65 && charValue <= 70) {
				// Uppercase A-F
				charValue -= 55;
			} else if (charValue >= 97 && charValue <= 102) {
				// Lowercase a-f
				charValue -= 87;
			}
			component = component * 16 + charValue;
		}

		return component;
	}

	function _adjustBrightness(
		uint256[3] memory rgbComponents,
		int256 brightnessFactor
	) private pure returns (uint256[3] memory) {
		// Adjust the brightness of RGB components
		for (uint256 i = 0; i < 3; i++) {
			int256 adjustedComponent = int256(rgbComponents[i]) +
				brightnessFactor;

			// Ensure the adjusted component stays within the valid range (0 to 255)
			adjustedComponent = _clamp(
				adjustedComponent,
				MIN_RGB_VALUE,
				MAX_RGB_VALUE
			);

			rgbComponents[i] = uint256(adjustedComponent);
		}
		return rgbComponents;
	}

	function clamp(
		uint256 value,
		uint256 minValue,
		uint256 maxValue
	) internal pure returns (uint256) {
		if (value < minValue) {
			return minValue;
		} else if (value > maxValue) {
			return maxValue;
		} else {
			return value;
		}
	}

	function _clamp(
		int256 value,
		uint256 minValue,
		uint256 maxValue
	) private pure returns (int256) {
		if (value < int256(minValue)) {
			return int256(minValue);
		} else if (value > int256(maxValue)) {
			return int256(maxValue);
		} else {
			return value;
		}
	}

	function _generateComplementaryColor(
		uint256[3] memory rgbComponents
	) private pure returns (string memory) {
		// Invert each RGB component to generate complementary color
		uint256[3] memory complementaryRGB;
		for (uint256 i = 0; i < 3; i++) {
			complementaryRGB[i] = MAX_RGB_VALUE - rgbComponents[i];
		}
		return
			_formatRGB(
				complementaryRGB[0],
				complementaryRGB[1],
				complementaryRGB[2]
			);
	}

	function _formatHEX(bytes3 value) private pure returns (string memory) {
		bytes memory buffer = new bytes(6);
		for (uint256 i = 0; i < 3; i++) {
			buffer[i * 2 + 1] = ALPHABET[uint8(value[i]) & 0xf];
			buffer[i * 2] = ALPHABET[uint8(value[i] >> 4) & 0xf];
		}
		return string(abi.encodePacked("#", buffer));
	}

	function uint256ToBytes3(uint256 value) internal pure returns (bytes3) {
		require(
			value <= 0xFFFFFF,
			"Value exceeds the maximum bytes3 representation"
		);

		bytes3 result;
		assembly {
			// Store the value in the first 3 bytes of the result
			mstore(result, value)
		}
		return result;
	}

	function _formatRGB(
		uint256 r,
		uint256 g,
		uint256 b
	) private pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					"rgb(",
					r.toString(),
					", ",
					g.toString(),
					", ",
					b.toString(),
					")"
				)
			);
	}

	function _formatRGBA(
		uint256 r,
		uint256 g,
		uint256 b,
		uint256 a
	) private pure returns (string memory) {
		if (a < MAX_ALPHA) {
			return
				string(
					abi.encodePacked(
						"rgba(",
						r.toString(),
						", ",
						g.toString(),
						", ",
						b.toString(),
						", 0.",
						a.toString(),
						")"
					)
				);
		} else {
			return
				string(
					abi.encodePacked(
						"rgba(",
						r.toString(),
						", ",
						g.toString(),
						", ",
						b.toString(),
						", 1)"
					)
				);
		}
	}

	function _formatHSL(
		uint256 h,
		uint256 s,
		uint256 l
	) private pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					"hsl(",
					h.toString(),
					", ",
					s.toString(),
					"%, ",
					l.toString(),
					"%)"
				)
			);
	}

	function _formatHSLA(
		uint256 h,
		uint256 s,
		uint256 l,
		uint256 a
	) private pure returns (string memory) {
		if (a < MAX_ALPHA) {
			return
				string(
					abi.encodePacked(
						"hsla(",
						h.toString(),
						", ",
						s.toString(),
						"%, ",
						l.toString(),
						"%, 0.",
						a.toString(),
						")"
					)
				);
		} else {
			return
				string(
					abi.encodePacked(
						"hsla(",
						h.toString(),
						", ",
						s.toString(),
						"%, ",
						l.toString(),
						"%, 1)"
					)
				);
		}
	}
}
