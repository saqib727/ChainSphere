// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// import { Test, console } from "forge-std/Test.sol";
// //importing our SocialMedia contract
// import { SocialMedia } from "../../src/SocialMedia.sol";
// import { DeploySocialMedia} from "../../script/DeploySocialMedia.s.sol";
// // import { FundSocialMedia, WithdrawSocialMedia } from "../../script/Interactions.s.sol";

// contract SocialMediaTestIntegration is Test{
    // // defining variable 'socialMedia' of type SocialMedia
    // SocialMedia socialMedia;

    // // create a fake user
    // address USER = makeAddr("Spo");

    // uint256 constant SEND_VALUE = 0.1 ether;
    // uint256 constant STARTING_BALANCE = 10 ether;
    // // This function sets up the test environment
    // function setUp() external{
    //     // deploy an instance of the FundMe contract
    //     DeployFundMe deploy = new DeployFundMe();
    //     fundMe = deploy.run();
    //     // use a cheatcode to allocate some ETH to USER
    //     vm.deal(USER, STARTING_BALANCE);
    // }

    // function testUserCanFundInteractions() public {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     fundFundMe.fundFundMe(address(fundMe));

    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    //     withdrawFundMe.withdrawFundMe(address(fundMe));

    //     assert(address(fundMe).balance == 0);
    // }
// }