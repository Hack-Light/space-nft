// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Strings} from "../../../dependencies/Strings.sol";
import {Base64} from "base64-sol/base64.sol";

import {DataTypes} from "../../types/DataTypes.sol";
import {TokenURIGen} from "../../utils/TokenURIGen.sol";
import {TypeCast} from "../../utils/TypeCast.sol";

library ShootingStarSVG {
    using Strings for uint256;

    function tokenURI(
        DataTypes.ShootingStar calldata shootingstar,
        uint256 tokenId
    ) external pure returns (string memory) {
        string memory name = string(
            abi.encodePacked("ShootingStar#", tokenId.toString())
        );
        string memory description = string(
            abi.encodePacked("This is a shooting star")
        );
        string memory image = Base64.encode(bytes(generateSVG(shootingstar)));

        return TokenURIGen.generateSVGTokenURI(name, description, image);
    }

    function renderTokenById(DataTypes.ShootingStar calldata shootingstar)
        public
        pure
        returns (string memory)
    {
        string memory path1 = string(
            abi.encodePacked(
                '<path d="M 561.392 -76.426 L 434.379 -4.943 C 434.379 -4.943 429.759 -2.162 430.159 -0.772 C 430.159 -0.772 430.159 1.014 433.775 -0.772 L 647.886 -125.523 L 561.392 -76.426 Z" style="mix-blend-mode: screen; fill: url(',
                "'#linear-gradient-62'",
                '); display: inline;">',
                '<title>shooting 1</title><animateMotion path="M -45.307 6.849 L -664.613 282.524" calcMode="linear" dur="',
                shootingstar.duration.toString(),
                's" fill="freeze" repeatCount="indefinite" /></path>'
            )
        );

        string memory path2 = string(
            abi.encodePacked(
                '<path d="M 404.477 -75.938 L 277.464 -4.455 C 277.464 -4.455 272.844 -1.674 273.244 -0.284 C 273.244 -0.284 273.244 1.502 276.861 -0.284 L 490.971 -125.036 L 404.477 -75.938 Z" style="mix-blend-mode: screen; fill: url(',
                "'#linear-gradient-62'",
                '); display: initial;"><title>shooting 2</title><animateMotion path="M 184.274 3.226 L -341.707 408.195" calcMode="linear" dur="',
                shootingstar.duration.toString(),
                's" fill="freeze" repeatCount="indefinite" begin="',
                (shootingstar.duration / 2).toString(),
                's" /></path>'
            )
        );

        return string(abi.encodePacked(path1, path2));
    }

    function generateSVG(DataTypes.ShootingStar calldata shootingstar)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<svg width="100%" height="100%" viewBox="0 0 1453 1274" fill="none" xmlns="http://www.w3.org/2000/svg">',
                    renderTokenById(shootingstar),
                    "</svg>"
                )
            );
    }
}
