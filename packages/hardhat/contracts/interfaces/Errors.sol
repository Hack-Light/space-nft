//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface Errors {
	error Space__InvalidMintFee();
	error Space__NoFeesAvailable();
	error Space__NotMinted();
	error Space__NotEnoughEth();
	error Space__WithdrawalFailed();
	error Space__ZeroAddress();
	error Space__InvalidFeeCollector();
	error Space__CannotHaveBody();
	error Space__BodyAlreadyAdded();
	error Space__NotBodyOwner();
	error Space__BodyAlreadyExists();
	error Space__BodyNotUsed();
	error Space__NotOwner();
	error Space__BodyUnavailable();
	error Space__NoBodies();
	error Space__BodiesCountMismatch();
}
