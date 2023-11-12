// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Strings} from "../../../dependencies/Strings.sol";
import {Base64} from "base64-sol/base64.sol";

import {DataTypes} from "../../types/DataTypes.sol";
import {TokenURIGen} from "../../utils/TokenURIGen.sol";
import {TypeCast} from "../../utils/TypeCast.sol";

library JupiterSVG {
    using Strings for uint256;

    function tokenURI(DataTypes.Jupiter calldata jupiter, uint256 tokenId)
        external
        pure
        returns (string memory)
    {
        string memory name = string(
            abi.encodePacked("Jupiter#", tokenId.toString())
        );
        string memory description = string(
            abi.encodePacked("This is a jupiter")
        );
        string memory image = Base64.encode(bytes(generateSVG(jupiter)));

        return TokenURIGen.generateSVGTokenURI(name, description, image);
    }

    function renderTokenById(DataTypes.Jupiter calldata jupiter)
        public
        pure
        returns (string memory)
    {
        string memory same = generateSameColor(jupiter);
        string memory first = generateFirst(jupiter);

        return
            string(
                abi.encodePacked(
                    first,
                    jupiter.color3,
                    ';"><title>ring</title></path><path d="M249.25389,74.5366a6.39255,6.39255,0,1,1-6.3926-6.3926A6.39183,6.39183,0,0,1,249.25389,74.5366Z" style="fill:',
                    jupiter.color5,
                    ';" /><path d="M264.33639,71.9516a1.5083,1.5083,0,1,1-1.5078-1.5088A1.508,1.508,0,0,1,264.33639,71.9516Z" style="fill:',
                    same,
                    '" /></g>'
                )
            );
    }

    function generateSameColor(DataTypes.Jupiter calldata jupiter)
        private
        pure
        returns (string memory)
    {
        string memory same1 = string(
            abi.encodePacked(
                jupiter.color5,
                '" /><path d="M259.16549,61.9677a2.15475,2.15475,0,1,1-2.1548-2.1543A2.1552,2.1552,0,0,1,259.16549,61.9677Z" style="fill:',
                jupiter.color5,
                '" /><path d="M237.61819,98.5258a4.23755,4.23755,0,1,1-4.2373-4.2373A4.23753,4.23753,0,0,1,237.61819,98.5258Z" style="fill:',
                jupiter.color5
            )
        );

        string memory same2 = string(
            abi.encodePacked(
                '" /><path d="M257.01069,92.0615a2.3701,2.3701,0,1,1-2.3706-2.3701A2.37047,2.37047,0,0,1,257.01069,92.0615Z" style="fill:',
                jupiter.color5,
                '" /><path d="M228.71189,75.3266a2.2981,2.2981,0,1,1-2.2978-2.2983A2.29832,2.29832,0,0,1,228.71189,75.3266Z"style="fill:',
                jupiter.color5
            )
        );

        return string(abi.encodePacked(same1, same2));
    }

    function generateFirst(DataTypes.Jupiter calldata jupiter)
        private
        pure
        returns (string memory)
    {
        string memory first = string(
            abi.encodePacked(
                '<g id="jupiter" style="" transform="matrix(1, 0, 0, 1, -11.066248, -5.984798)"><title>jupiter</title><path d="M285.041,87.167a33.32616,33.32616,0,1,1-33.32621-33.3262A33.3264,33.3264,0,0,1,285.041,87.167Z" style="fill:',
                "rgb(26, 194, 216)",
                ';"><title>full</title></path><path d="M265.16459,56.6689A33.33112,33.33112,0,0,1,228.334,110.913a33.32763,33.32763,0,1,0,36.83059-54.2441Z" style="fill:',
                "rgb(25, 168, 178)",
                ';"><title>half</title></path><path d="M304.98439,54.0551c-2.5078-3.5044-14.4551.4141-30.1573,9.1553a38.21521,38.21521,0,0,1,3.8653,4.3569c4.355-1.6235,7.3711-1.9511,8.30661-.643,2.376,3.3218-9.55031,15.9282-26.64161,28.1557-17.0898,12.2281-32.8716,19.4483-35.248,16.126-.521-.7275-.355-1.8999.4004-3.417a25.48785,25.48785,0,0,1-3.9053-5.6645c-10.8687,10.3935-16.7324,18.80417-14.481,21.95065,3.7583,5.25245,28.7119-6.16406,55.7359-25.499C289.88279,79.2407,308.74319,59.3081,304.98439,54.0551Z" style="fill:'
            )
        );

        return first;
    }

    function generateSVG(DataTypes.Jupiter calldata jupiter)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<svg width="100%" height="100%" viewBox="0 0 1453 1274" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    renderTokenById(jupiter),
                    "</svg>"
                )
            );
    }
}
