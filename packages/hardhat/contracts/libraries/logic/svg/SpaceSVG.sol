//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// import "hardhat/console.sol";

import { Strings } from "../../../dependencies/Strings.sol";
import { Base64 } from "base64-sol/base64.sol";

import { DataTypes } from "../../types/DataTypes.sol";
import { TokenURIGen } from "../../utils/TokenURIGen.sol";
import { TypeCast } from "../../utils/TypeCast.sol";

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

library SpaceSVG {
	using Strings for uint256;
	using Strings for int256;

	function tokenURI(
		address[] calldata bodies,
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		DataTypes.Space calldata space,
		uint256 tokenId
	) external view returns (string memory) {
		string memory name = string(
			abi.encodePacked("Space#", tokenId.toString())
		);
		string memory description = "Welcome to your own space";
		string memory image = Base64.encode(
			bytes(generateSVG(bodies, s_bodiesById, space, tokenId))
		);

		return TokenURIGen.generateSVGTokenURI(name, description, image);
	}

	function renderSpace(
		DataTypes.Space calldata space
	) internal pure returns (string memory) {
		string memory wholeRiver = string(
			abi.encodePacked(
				'<rect x="19.0674" y="224.4296" width="504.98339" height="373.9561" style="fill:',
				"rgb(26, 194, 216)",
				'"><title>whole-river</title></rect>',
				'<path d="M418.14159,254.499c-15.4404,0-122.89259-2.8355-126.6748,5.9883-3.7813,8.8227,69.9541,12.7939,118.7969,15.0625,48.8418,2.269,101.4648,11.7216,86.0254,13.2968-15.4405,1.5757-50.2207,3.4673-36.1397,5.9878,14.082,2.5201,77.418,10.0826,77.418,10.0826l-2.2051-46.6358Z" style="fill:',
				space.riverColor3,
				';"><title>river-color-3</title></path>'
			)
		);

		string memory text = string(
			abi.encodePacked(
				'<text transform="matrix(0.966634, 0, 0, 0.951613, 137.347809, 741.051331)" style="fill: rgb(241, 242, 242); font-family:',
				"'Marker Felt'",
				'; font-size: 48px; font-weight: 700; white-space: pre;">',
				space.text,
				"</text>"
			)
		);

		(
			string memory exMountain,
			string memory smallMountain,
			string memory firstSet
		) = generateMountain(space);

		(
			string memory unnamedPath1,
			string memory unnamedPath2
		) = generateUnnamedPaths(space);

		return
			string(
				abi.encodePacked(
					"#greyStars",
					"#yellowStars",
					"#whiteStars",
					"#sun",
					wholeRiver,
					exMountain,
					unnamedPath1,
					smallMountain,
					unnamedPath2,
					firstSet,
					text,
					"</g></g></g></svg>"
				)
			);
	}

	function renderTokenById(
		address[] calldata bodies,
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		DataTypes.Space calldata space,
		uint256 tokenId
	) public view returns (string memory) {
		string memory token = renderSpace(space);

		string memory wholeSky = string(
			abi.encodePacked(
				'<rect x="15.4546" y="17.6699" width="512.58249" height="719.2373" style="fill:',
				"rgb(38, 22, 63)",
				';"><title>whole-sky</title></rect>'
			)
		);

		string memory start = generateStart();

		uint256 numOfBodies = bodies.length;

		for (uint256 i = 0; i < numOfBodies; i++) {
			address body = bodies[i];
			uint256 bodyTokenId = s_bodiesById[body][tokenId];

			if (bodyTokenId > 0) {
				token = string(
					abi.encodePacked(
						Body(body).renderTokenById(bodyTokenId),
						token
					)
				);
			}
		}

		return
			string(
				abi.encodePacked(
					start,
					wholeSky,
					token
				)
			);
	}

	function generateSVG(
		address[] calldata bodies,
		mapping(address => mapping(uint256 => uint256)) storage s_bodiesById,
		DataTypes.Space calldata space,
		uint256 tokenId
	) private view returns (string memory) {
		return
			string(
				abi.encodePacked(
					renderTokenById(bodies, s_bodiesById, space, tokenId)
				)
			);
	}

	function generateMountain(
		DataTypes.Space calldata space
	) private pure returns (string memory, string memory, string memory) {
		string memory exMountain1 = string(
			abi.encodePacked(
				'<g><title>extreem-mountain</title><path d="M525.59279,267.7348c-2.2051-17.6465-1.8897-91.6972-8.5069-88.8613-6.6171,2.8364-15.4404,9.1382-24.5781,16.3852-9.1387,7.2476-12.9209,15.7564-18.9072,17.3316a42.70639,42.70639,0,0,0-9.76759,3.7817s-4.41211-12.289-7.87791-9.4536c-3.4658,2.8364-9.45409,17.0161-23.0039,22.3721-13.5489,5.3569-22.0576,8.8237-24.2637,14.1807-2.2051,5.3569-2.52049,5.9873-8.1924,10.3984-5.6719,4.4116-7.248,6.9321-4.41109,6.9321,2.83589,0,63.65229,1.5752,84.76459,2.521C501.96,264.2675,525.59279,267.7348,525.59279,267.7348Z" style="fill:',
				space.mountainDarkColor,
				';"><title>mountain-dark</title></path><path d="M525.59279,267.7348s-23.63279-3.4673-44.7442-4.4121c-5.1201-.229-12.5791-.4951-20.97559-.7671-1.68261-4.414-.28021-10.8633-2.02731-14.3584-2.2061-4.4106-12.9209,4.0967-12.9209,4.0967s4.7285-12.6045,6.9336-18.2764c2.2051-5.6718.6309-7.247-1.5762-10.7529-2.2051-3.5068,1.26081-6.8926,3.46581-10.0444a18.85046,18.85046,0,0,0,2.10059-6.208c.0352-.0293.0723-.0655.1065-.0938,3.4658-2.8354,7.87791,9.4536,7.87791,9.4536s.89649-.52,2.49709-1.2358a161.94706,161.94706,0,0,0,15.1474,17.3052s4.7286-17.0152,9.1387-20.7959c4.4121-3.7813,4.0977-5.6719,4.7276-10.7154.6298-5.0405,5.6708-7.8769,13.2353-9.7675,5.2236-1.3057,7.292-6.6739,9.83591-11.7373C523.66989,186.4624,523.54689,251.3632,525.59279,267.7348Z" style="fill:',
				space.mountainLightColor,
				';"><title>mountain-light</title></path><path d="M482.11719,230.8554s3.8564-11.5713,5.2344-13.7749c1.3779-2.2036,7.43841-10.7446,7.43841-10.7446s1.92879-8.541,2.75589-10.4692c-3.582,3.5815-3.3076,4.4082-4.4092,8.54-1.1006,4.1328-8.2646,11.5708-8.8154,14.3267C483.77049,221.4882,482.11719,230.8554,482.11719,230.8554Z" style="fill:',
				"rgb(255, 255, 255)"
			)
		);
		string memory exMountain2 = string(
			abi.encodePacked(
				';"><title>mountain-white</title></path><path d="M522.61619,244.6298s-3.3057-36.3652-3.8574-40.2231c-7.1631,10.7451-14.3242,28.3774-21.4883,31.4072-7.1631,3.0313-5.7861-17.6318-5.7861-22.3159a112.58543,112.58543,0,0,0-9.6426,20.1118s14.0508,22.315,19.28521,26.999c5.23429,4.6841,23.14159,3.5821,23.14159,3.5821Z" style="fill:',
				space.mountainGreyColor,
				';"><title>mountain-gray</title></path></g>'
			)
		);

		string memory exMountain = string(
			abi.encodePacked(exMountain1, exMountain2)
		);

		string memory fullMountain1 = string(
			abi.encodePacked(
				'<g style=""><title>full-hill</title><path d="M237.958,277.7221s119.51269,34.4649,111.09379,34.9082c-8.4161.4419-50.9473-.8862-60.251-3.5439-9.3047-2.6592-22.1519,1.0532-14.1773,3.6279,7.9742,2.5752.4429,4.5142-16.39249,0-16.835-4.5146-98.2413-10.2402-127.4507-15.5727-29.21-5.333-45.3838-10.6504-45.3838-10.6504Z" style="fill:',
				space.mainRiverColor,
				';"><title>main-river</title></path><path d="M243.31589,284.4243c.2954-7.6807-2.3628-42.2354-5.9072-44.0083-3.5444-1.7715-7.3828-5.0205-7.6792-12.1099-.2954-7.0879-10.6333-68.8169-12.1094-68.522-1.477.2959-35.14739,34.5567-40.46379,36.6241-5.316,2.0678-19.7886,12.7002-30.126,21.2656-10.3374,8.5649-19.7886,22.7422-24.5147,22.7422-4.7256,0-10.3369-.8853-13.8818,3.249-3.5444,4.1353-13.8818,13.291-16.8345,14.1772-2.9536.8868-12.9956,15.0635-15.0635,20.9698-2.0673,5.9077-4.7251,9.7475,21.8565,12.7011,26.582,2.9522,89.7881.5909,108.09959,0C225.00339,290.9218,243.31589,284.4243,243.31589,284.4243Z" style="fill:',
				space.mountainDarkColor,
				';"><title>mountain-dark</title></path><path d="M95.0474,271.1333c2.0688-6.4976,6.2031-3.2491,12.1103-9.7466,5.9068-6.4976,4.1353-7.6797,5.9068-14.4737,1.7714-6.7915,16.5405,3.545,19.7885,6.2032,3.2491,2.6582,5.0205-1.1807,7.6792-6.793,2.6582-5.6113,31.3081-32.7842,38.1016-35.7378,6.792-2.9536,0,6.793,0,6.793s12.1099-14.1763,23.03659-29.5347a147.535,147.535,0,0,0,14.7378-27.1377,5.72378,5.72378,0,0,1,1.2119-.9219c1.4761-.2949,11.814,61.4341,12.1094,68.522.2964,7.0894,4.1348,10.3384,7.6792,12.1099,3.5444,1.7729,6.2026,36.3276,5.9072,44.0083,0,0-18.3125,6.4975-36.624,7.0888-18.31149.5909-81.51759,2.9522-108.09959,0-3.2593-.3613-6.0757-.7382-8.5108-1.1294C91.8159,283.1792,93.9409,274.6147,95.0474,271.1333Z"style="fill: '
			)
		);

		string memory fullMountain2 = string(
			abi.encodePacked(
				space.mountainMediumColor,
				';"><title>mountain-medium</title></path><path id="big_rock_hightlight" data-name="big rock hightlight" d="M178.6338,292.9668s4.7251-33.9429,5.6113-42.6568c.8862-8.7119,9.7466-20.084,11.5191-10.3374,1.7719,9.7466,6.20259-15.0625,12.70019-34.1133,4.6259-13.561,7.229-33.8491,8.3335-45.4853a3.51332,3.51332,0,0,1,.8222-.5899c1.4761-.2949,11.814,61.4341,12.1094,68.522.2964,7.0894,4.1348,10.3384,7.6792,12.1099,3.0459,1.5229,5.4829,31.9282,5.9072,44.0083L217.437,290.559Z" style="fill: ',
				space.mountainLightColor,
				';"><title>mountain-light</title></path><path d="M214.95309,170.167s-7.125,28.5014-7.125,29.6884c0,1.1875-7.521,32.4605-7.521,32.4605s11.083-22.1685,11.083-24.9395C211.39009,204.6059,214.95309,170.167,214.95309,170.167Z" style="fill:',
				"rgb(255, 255, 255)",
				';"><title>mountain-white</title></path></g>'
			)
		);
		string memory fullMountain = string(
			abi.encodePacked(fullMountain1, fullMountain2)
		);

		string memory whites = string(
			abi.encodePacked(
				'<path d="M31.2495,587.2011s23.8311-1.292,29.5733-7.7529c5.7426-6.46,3.0156-14.2109,36.0346-18.9492,33.0196-4.7373,38.9048-7.6084,53.835-13.0635-18.5191,10.3359-41.3462,18.0889-43.9297,18.2315-2.5835.1435-28.1372,2.7275-32.3008,7.7519-4.1631,5.0244,10.7671,3.0147,22.1089,0-17.6582,9.332-28.8555,7.4668-35.7466,10.9121C53.9326,587.7763,40.1494,589.3535,31.2495,587.2011Z" style="fill:#fff" />',
				'<path d="M246.97309,553.5322s6.3472-16.9902,9.3746-16.8926c3.0268.0977,14.9404,5.0762,22.8501,4.3936-7.6163,1.5625-21.8741-3.6133-23.24079-.8789A59.35715,59.35715,0,0,1,246.97309,553.5322Z" style="fill:#fff" />',
				'<path d="M283.39649,536.249s-2.44-13.7705,12.5976-17.8711c15.0381-4.0996,13.4756-13.8652,29.003-20.3096-2.7354,7.5196-5.37109,4.4912-10.0586,11.8154-4.68749,7.3233-17.5772,12.9874-23.0459,13.9649C286.42379,524.8252,283.39649,536.249,283.39649,536.249Z" style="fill:#fff" />',
				'<path d="M427.23929,484.9853c-.5538.4121,9.374-7.5195,13.2802-18.75,3.9063-11.2295,7.7139-8.9844,19.1397-4.1006-8.9844-.5859-13.3779-1.7578-16.3076,5.5664-2.9287,7.3233-3.6143,11.9141-2.6368,17.5772C437.68749,478.7353,438.76169,476.3925,427.23929,484.9853Z" style="fill:#fff" />',
				'<path d="M481.44729,447.248s7.166-17.7685,31.414-18.0635C500.78609,433.7988,495.09279,434.4863,481.44729,447.248Z" style="fill:#fff" />'
			)
		);

		string memory riverWhites = string(
			abi.encodePacked(
				'<path id="down_rock_shadow-2" data-name="down rock shadow" d="M499.24119,336.5542c-25.6963,2.2153-21.2656-.8853-42.9756,0-21.708.8857-78.1679.3252-78.1679.3252s2.8535,3.6611,36.5224,4.5483c33.67191.8862,65.5703,2.2143,55.37991,3.1006-10.18851.8862-44.89361,3.1015-52.57321,3.1015-7.67779,0,9.15621.8858,24.663,2.2154,15.5059,1.3281,34.5567,3.5444,73.9854,3.5444,39.4307,0,15.9492-16.9995,15.9492-16.9995Z" style="fill: rgb(255, 255, 255);"><title>river-white</title></path>',
				'<path id="river_highlight" data-name="river highlight" d="M30.5132,469.0205c30.5693,0,87.7197,2.6582,73.1001,3.5439-14.6201.8858,17.7212,7.0879,45.6323,6.2022,27.9107-.8858,37.6572,4.874,11.0757,5.3164-26.582.4433-109.8716,5.4658-88.606,5.6132,21.2657.1465,62.4668,2.0655,44.7451,3.544-17.7207,1.4756-101.0058,5.4238-101.0058,5.4238V470.792Z" style="fill:#fff"><title>river-white</title></path>',
				'<path id="river_highlight-2" data-name="river highlight" d="M15.4546,421.7641c29.0879-1.477,55.0801-1.477,65.1211,0,10.042,1.4766,10.043.2935,24.81,1.4766,14.7681,1.1816,49.6197,4.3286,35.4424,4.8227-14.1772.4932-29.6152-1.6718-65.313.2969-35.6977,1.9688-39.833,9.1992-24.4746,7.6514,15.3589-1.5479,50.4004,2.8828,34.356,3.3252-16.044.4433-7.1084,2.8623-36.7188,2.2431-29.6103-.6181-33.2231,0-33.2231,0Z" style="fill:#fff"><title>river-white</title></path>',
				'<rect id="frame" x="28.0542" y="26.875" width="479.15969" height="705.3056" style="fill: none;" />'
			)
		);

		string memory smallMountain1 = string(
			abi.encodePacked(
				'<g><title>small hill</title><path d="M381.83689,261.9765c-4.4306-3.5434-12.9961-24.8095-15.3584-25.9912-13.291,12.7012-25.6963,25.6978-26.582,25.9912-.8858.2964,11.8144,2.6587,19.4941,2.6587C367.06929,264.6352,381.83689,261.9765,381.83689,261.9765Z" style="fill:',
				space.mountainDarkColor,
				';"><title>mountain-dark</title></path><path d="M357.14159,264.5781c2.1025-6.1148,5.752-16.3223,6.6787-20.0269.4541-1.8169,1.2578-4.8989,2.0752-8.0073.1943-.1851.3877-.3726.583-.5586,2.3623,1.1817,10.9278,22.4478,15.3584,25.9912,0,0-14.7676,2.6587-22.4463,2.6587C358.67869,264.6352,357.92379,264.6147,357.14159,264.5781Z" style="fill:',
				space.mountainLightColor
			)
		);
		string memory smallMountain2 = string(
			abi.encodePacked(
				';"><title>mountain-light</title></path><path d="M375.41309,260.7959c6.4238-.6656,35.6055,10.8393,31.3154,12.8398-4.29,2.002-21.3467-3.98-31.3154-5.7515-9.9688-1.7724-26.374-4.0883-26.374-4.0883Z" style="fill:',
				space.mainRiverColor,
				';"><title>main-river</title></path></g>'
			)
		);
		string memory smallMountain = string(
			abi.encodePacked(smallMountain1, smallMountain2)
		);

		string memory firstSet = string(
			abi.encodePacked(riverWhites, fullMountain, whites)
		);

		return (exMountain, smallMountain, firstSet);
	}

	function generateUnnamedPaths(
		DataTypes.Space calldata space
	) private pure returns (string memory, string memory) {
		string memory unnamedPath1a = string(
			abi.encodePacked(
				'<path d="M222.78759,276.4506c10.1895-.4428,158.605,15.1665,128.0356,16.2222-30.5693,1.0567-138.6694,6.3745-165.25039,20.1074-26.5821,13.7334-36.772,26.1392,0,40.3155,36.77139,14.1772,128.40569,38.9873,202.64989,42.9746,74.2451,3.9868,118.9912,8.8598,118.9912,8.8598V731.8886H244.939s7.08829-127.1513-18.60791-199.8076c-25.6954-72.6572-81.51759-126.2641-123.16219-144.8716C61.5234,368.602,7.9165,356.6406,16.335,339.3628c8.4165-17.2789,89.0488-25.6973,77.0874-31.899-11.962-6.2021-70.0723-2.2148-72.2144-12.8481-2.1426-10.6328,17.8389-16.9834,45.8384-20.3794S222.78759,276.4506,222.78759,276.4506Z" style="fill:',
				space.riverColor1,
				';"><title>river-color-1</title></path><path d="M507.21389,446.622c-5.0391-.2675-14.8877-1.3427-32.6358-5.0703-29.53509-6.2021-76.497-15.3569-73.8388-24.2182,2.33-7.7637,85.8418-7.3643,106.4746-7.146Z" style="fill:',
				space.riverColor2,
				';"><title>river-color-2</title></path><path d="M405.85249,258.5947c-12.9199,0-80.9834.3174-80.9834,3.4682,0,3.1504,46.3213,3.7813,67.4327,4.0953,21.11321.3164,89.8076,4.288,103.042,9.3916,13.2353,5.1045,13.2333,14.5571,4.4101,15.8183-8.8213,1.2598-6.9307,2.521.6318,3.4663,7.5616.9458,25.2071,1.5508,25.2071,1.5508l1.2627-34.3223Z" style="fill:'
			)
		);
		string memory unnamedPath1b = string(
			abi.encodePacked(
				space.riverColor2,
				';"><title>river-color-2</title></path><path d="M448.15629,258.5947s34.9765,7.2495,44.1933,11.5029c9.2168,4.2539,27.415,16.9531,27.415,16.9531s3.0723-20.9716-3.3085-22.6245C510.07419,262.7714,448.15629,258.5947,448.15629,258.5947Z" style="fill:',
				space.mainRiverColor,
				';"><title>main-river</title></path>'
			)
		);

		string memory unnamedPath1 = string(
			abi.encodePacked(unnamedPath1a, unnamedPath1b)
		);

		string memory unnamedPath2a1 = string(
			abi.encodePacked(
				'<path d="M196.207,282.0615c20.82229,0,46.07519,6.2016,13.29009,14.1763-32.78319,7.9751-63.79589,20.3798-65.56739,33.228-1.773,12.8481,21.2646,34.5556,75.75779,57.1504,54.4937,22.5952,214.8701,80.6318,251.1992,97.0244,36.3272,16.3926,45.1885,27.4668,45.1885,27.4668V733.9531H403.10249s-46.9609-119.6172-88.6054-178.9854c-41.646-59.3652-104.1304-116.0732-155.07029-150.6298-50.9405-34.5567-79.7373-53.1646-80.1802-65.5684-.4429-12.4053,37.6577-19.4932,37.6577-29.6831,0-10.1895-62.0244-16.8355-62.4673-22.1524-.4429-5.3159,28.7974-7.5312,53.1641-9.3027C131.9668,275.8584,196.207,282.0615,196.207,282.0615Z" style="fill:',
				space.riverColor2,
				';"><title>river-color-2</title></path>',
				'<path d="M154.9307,284.2768c8.0493,0,10.559,15.063,0,21.2652-10.5586,6.2021-32.7105,25.2519-32.7105,34.1132,0,8.8604,29.2407,27.9107,53.1646,37.6573,23.92379,9.7465,223.73039,91.2656,258.72949,112.0879,35,20.8222,81.9609,52.2773,81.9609,52.2773l-2.2148,67.3398S447.40529,528.625,404.875,502.8095c-42.53121-25.8144-114.30271-70.1172-151.51761-85.624-37.2143-15.5063-117.84569-49.6196-131.13719-63.353-13.291-13.7349-11.0747-21.2661,0-31.898,11.0762-10.6333,25.7315-18.6279,11.0762-23.9238-14.6558-5.2974-54.4927-14.6211-46.9614-13.7339C93.8667,285.1626,154.9307,284.2768,154.9307,284.2768Z" style="fill:',
				space.mainRiverColor
			)
		);
		string memory unnamedPath2a2 = string(
			abi.encodePacked(
				';"><title>main-river</title></path>',
				'<path id="down_rock_under" data-name="down rock under" d="M514.30369,428.3603c-19.4932-.0986-30.126,10.9766-34.999,20.7246-4.874,9.7451-6.2031,13.7334-15.9502,12.8467-9.7461-.8857-16.835-11.2783-22.1504.1211-5.3174,11.3975-11.9619,26.0185-27.4687,27.3477-15.5069,1.3281-59.3663-7.5313-75.7579,0-16.39249,7.5312-27.4687,15.5048-31.8994,20.8222-4.4306,5.3154-7.4228,4.9854-13.29,7.0879-5.8672,2.1035-9.3042,5.7598-11.0767,14.6201-1.7719,8.8614-1.7519,9.7471-13.0591,7.0889-11.3066-2.6592-12.1938-6.2246-16.6235,1.3184-4.4307,7.541-4.8735,20.3906-23.0376,20.3906s-41.20209-24.8106-69.11279-18.1651c-14.0718,3.3496-30.126,13.7344-49.6196,15.5069-19.4932,1.7715-40.3154,3.9863-46.9614,10.1884-6.6455,6.2032-10.6324,9.3047-16.835,10.6338s-23.4805,4.8731-23.4805,4.8731V736.1679H524.05079Z" style="fill:',
				space.mountainLightColor,
				';"><title>mountain-light</title></path>'
			)
		);
		string memory unnamedPath2a = string(
			abi.encodePacked(unnamedPath2a1, unnamedPath2a2)
		);

		string memory unnamedPath2b1 = string(
			abi.encodePacked(
				'<path id="down_rok_top" data-name="down rok top" d="M510.75879,439.3369c-8.417,1.3291-17.2783,4.4306-18.6074,12.8486-1.3291,8.416-3.9873,11.5186-11.5186,11.5186-7.5312,0-13.291,5.7597-12.4053,7.9746.8868,2.2158-4.8818,8.6181-12.5849,5.5254-7.7031-3.0938-14.4385-6.1084-13.9961.8281.4433,6.9375,8.7588,14.9287-3.8174,13.5918-12.5752-1.3379-12.1318-3.1104-11.6885,2.6484.44241,5.7608-6.2715,6.1582-25.5088,5.959-19.2373-.1982-33.8574-4.1543-33.8574.0381,0,4.1934-5.7598,3.1016-14.6211,2.54-8.86029-.5615-14.6191-.1181-15.0625,5.1973-.4433,5.3174-7.5312,9.3037-15.9492,9.3037-8.417,0-11.6611,7.415-13.291,16.8359s-6.6445,14.1758-11.51859,11.962c-4.874-2.2149-13.291.8857-14.17721,3.1005-.8862,2.2149-7.0884,8.8614-7.9736,3.544-.8868-5.3154-10.6285-9.7461-12.84719-2.6572-2.21681,7.0888,3.98579,10.1894-15.50731,10.1894-19.49369,0-52.27789-16.8349-65.56889-16.8349-13.2915,0-24.3672,4.872-19.9365,9.3027,4.4297,4.4316,7.3198,6.2031-.9917,7.5322-8.3115,1.3281-6.0962,3.9873-4.3242,7.5303,1.7724,3.5449,12.8471,6.6465-12.8487,7.5322-25.6963.8867-40.7588,7.0889-40.3154,13.7344.4429,6.6455-1.7725,3.5439-14.1763,8.8603-12.4057,5.3164-38.5444,8.8604-25.6972,11.0752,12.8481,2.2159,56.2651-4.872,46.9614,0-9.3032,4.875-24.0278,11.0772-23.5327,15.0635.4951,3.9883-8.3652,2.2158-18.5547,2.6582-10.1899.4434-15.9492,5.7598-21.2656,9.3037-5.3164,3.545-17.522,4.8741-17.522,4.8741v91.2636L544.75679,779Z" style="fill:',
				"rgb(11, 31, 61)",
				';"><title>main-river</title></path><path id="down_rock_shadow" data-name="down rock shadow" d="M24.5415,653.9961s47.1646-2.2901,62.2739-5.0372c15.1114-2.746,29.7637-28.8476,78.2998-29.3046-13.2783,7.3261-61.3564,13.2783-26.0996,18.3154,35.2583,5.0361,72.34769,15.5683,89.74809,18.3154,17.4004,2.749,102.11131,32.0528,102.11131,32.0528l79.67289,4.58,197.79589,98.1123L176.9873,806.497,10.2881,791.0302Z" style="fill:',
				"rgb(8, 24, 48)"
			)
		);
		string memory unnamedPath2b2 = string(
			abi.encodePacked(
				';"><title>mountain-dark</title></path><path d="M531.43259,506.5586c-39.8359-3.2051-47.1631,13.7363-58.1533,14.1943-10.98929.458-27.4727-4.5781-44.873-.916-17.3995,3.6631-79.2168,3.6631-73.7217,9.6162,5.4941,5.9521,51.2842,9.1562,28.3896,16.9414-22.8955,7.7851-73.7217,25.1846-73.7217,25.1846s-46.7046,31.5918-54.9462,38.0039c-8.2422,6.4101,151.1044,17.4004,166.2158,18.7734,15.1113,1.3731,104.8584,63.6465,105.7734,61.8145C527.31149,688.3388,531.43259,506.5586,531.43259,506.5586Z" style="fill:',
				"rgb(8, 24, 48)",
				';"><title>mountain-dark</title></path>'
			)
		);
		string memory unnamedPath2b = string(
			abi.encodePacked(unnamedPath2b1, unnamedPath2b2)
		);

		string memory unnamedPath2 = string(
			abi.encodePacked(unnamedPath2a, unnamedPath2b)
		);

		return (unnamedPath1, unnamedPath2);
	}

	function generateStart() private pure returns (string memory) {
		string memory start = string(
			abi.encodePacked(
				'<?xml version="1.0" encoding="utf-8"?>',
				'<svg viewBox="0 0 608.34378 836.7558" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
				"#definition",
				'<g style="isolation: isolate;"transform="matrix(0.9984520673751832, 0, 0, 1, 2.2737367544323206e-13, 2.842170943040401e-14)">',
				'<g id="Layer_1" data-name="Layer 1" style="">',
				'<rect width="501.376" height="792.8" style="fill: rgba(157, 157, 158, 0);" />',
				'<g style="clip-path:',
				"url('#clip-path')",
				';" transform="matrix(1.034518, 0, 0, 1.050847, 21.041157, -1.503412)">'
			)
		);

		return (start);
	}
}
