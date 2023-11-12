//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library DataTypes {
	struct Body {
		address _address;
	}

	struct Space {
		string wholeSkyColor;
		string wholeRiverColor;
		string mountainDarkColor;
		string mountainGreyColor;
		string riverColor3;
		string riverColor1;
		string riverColor2;
		string mainRiverColor;
		string mountainLightColor;
		string mountainMediumColor;
		string text;
	}

	struct Jupiter {
		string color1;
		string color2;
		string color3;
		string color4;
		string color5;
	}

	struct Planet {
		string mainColor;
		string halfColor;
	}

	struct ShootingStar {
		uint256 duration;
	}
}
