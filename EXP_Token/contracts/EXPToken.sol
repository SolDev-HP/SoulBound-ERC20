// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "../interfaces/ISoulbound.sol";

/** 
 * @title Soulbound ERC20 token implementation - named EXPToken
 * Requirement: 
 *  - Implement a setApprovedMinter(address, bool) onlyOwner function
 *  - No limit on total supply
 *  - Transfer capabilities must be disabled after minting (soulbound)
 * Updates:
 *  - In addition to requirements, we can now generate random numbers 
 *    using API3 QRNG implementation and Airnode on chains 
 *    See: https://api3.org/QRNG
 * @author SolDev-HP (https://github.com/SolDev-HP)
 * @dev Implement ERC20 in a way that limits tokens capabilities such as 
 * transfer, approval and make it soulbound - once minted, it can not 
 * be transferred
 */

contract EXPToken is ERC20, Ownable, ISoulbound, RrpRequesterV0 {

    /**
     * ==================================================================
     *                          STATE VARIABLES
     * ==================================================================
     */
    // Per user experience point capping @ 100 EXP Tokens
    uint256 internal constant MAXEXP = 100 * 10 ** 18;
    // To test received random number from Airnode
    uint256 public randomNumber;

    // Now we need storage for parameters 
    // airnode - this is the location of Airnode that has implemented Airnode Rrp
    // endpointIdUnit256 - A path on airnode, that will provide us the random result.
    // It's like we are requesting randomness, but from a specific path that handles uint256
    // sponsor wallet - The address that happens to fulfill the request through airnode
    address public aApiProviderAirnode;
    address public aSponsorWallet;
    bytes32 public btEndpointIdUint256;
    
    /**
     * @dev mapping to map token admins who are allowed to perform 
     * mint operation
     */
    mapping(address => bool) public mTokenAdmins;
    // mapping of who requested for randomness based on requestId that we receive
    // when we send a request for randomness, but it has to stay internal so we can utilize it
    // within EXPToken contract 
    mapping(bytes32 => address) internal mRequestIdToWhoRequested;
    // the mapping that will store requestId and corresponding details if 
    // request has been fulfilled or not. 
    // So when let's say admin calls generateRandomExperienceForPlayer(address _player)
    // That function should make a request for random number 
    // This request creates a request ID and is added into the mapping with boolean indicating 
    // that request is yet to fulfilled. Once we receive a callback from the airnode 
    // this request ID will then be marked false, as it has been fulfilled now 
    mapping(bytes32 => bool) internal mExpectingRequestWithIdToBeFulfilled;

    /**
     * ==================================================================
     *                              ERRORS
     * ==================================================================
     */
    
    // Error to indicate that action can only be performed by token admins 
    error OnlyTokenAdminsAllowed();
    // Error to indicate that referenced address is a zero address 
    error InvalidAddress();
    // Error to indicate that performed action has no effects 
    // And hence better to revert instead of unnecessarily access 
    // other state variables  
    error ActionHasNoEffects();

    /**
     * ==================================================================
     *                              EVENTS
     * ==================================================================
     */
    // Events to notify whether request was made, or response was received 
    event RandomNumberRequested(bytes32 indexed btRequestId);
    event RandomNumberReceived(bytes32 indexed btRequestId, uint256 iResponse);


    /**
     *  @dev contructor expects token name (string), token symbol (string)
     *  and our contract is also an instance of requester for 
     *  request-response protocol implemented by on chain AirnodeRrpV0
     *  API3's airnode-protocol->RrpRequesterV0 construction simply sets 
     *  the interface with AirnodeRrpV0 address given by aRrpAirnode 
     *  so that it can SetSponsorshipStatus for this requester 
     */
    constructor(string memory sTokenName, string memory sTokenSymbol, address aRrpAirnode)
        ERC20(sTokenName, sTokenSymbol)
        RrpRequesterV0(aRrpAirnode)
    {
        // Set deployed the first token admin 
        mTokenAdmins[_msgSender()] = true;
        // We don't need anything else except for setting up following things here
        // IERC165, supportsInterface - IERC20, ISoulbound 
    }


    /**
     * ==================================================================
     *                  FUNCTIONS (Public) - ERC20 
     * ==================================================================
     */

    // We override following functions from OpenZeppelin's ERC20   
    // to make sure EXPToken follows properties of being a soulbound token 
    function transfer(address, uint256) public override returns (bool) {
        // Intended revert, action not allowed 
        revert TokenIsSoulbound();
    }

    function allowance(address, address) public view override returns (uint256) {
        // Always revert 0. There's no allowance for anyone
        return 0;
    }

    function approve(address, uint256) public override returns (bool) {
        // Intended revert, approval is not possible
        revert TokenIsSoulbound();
    }

    function transferFrom(address, address, uint256) public override returns (bool) {
        // Intended revert, cannot be transferred 
        revert TokenIsSoulbound();
    }

    function increaseAllowance(address, uint256) public override returns (bool) {
        // Intended revert, there is no allowance
        revert TokenIsSoulbound();
    }

    function decreaseAllowance(address, uint256) public override returns (bool) {
        // Intended revert, there is no allowance
        revert TokenIsSoulbound();
    }
    /**
     * ==================================================================
     *                  FUNCTIONS (Public) - ISoulbound 
     * ==================================================================
     */

    /** 
     * @notice Set admins
     * @dev ability to set or unset admins, generates TokenAdminSet event
     */
    function setTokenAdmin(address aWhichAddress, bool bIsAdmin) 
        external 
        onlyOwner 
    {
        // Check address validity 
        if (aWhichAddress == address(0)) { revert InvalidAddress(); }
        // Check if operation actually has any effects or should 
        // be disregarded 
        if (mTokenAdmins[aWhichAddress] == bIsAdmin) { revert ActionHasNoEffects(); }
        // Set token admin
        mTokenAdmins[aWhichAddress] = bIsAdmin;
        // Emit the token admin set event 
        emit TokenAdminSet(aWhichAddress, bIsAdmin);
    }


    /// @dev gainExperience function to add experience points to user's EXP balance 
    /// Need to make sure we cap experience to max exp limit
    function gainExperience(address aWhichPlayer, uint256 iHowMuchGained) public {
        // Make sure only token admins can call this function 
        if (!mTokenAdmins[_msgSender()]) { revert OnlyTokenAdminsAllowed(); }
        // Make use of state variable only once if it's being used multiple times within function
        // In this case, balanceOf will access user's balance state var 
        uint256 _bal = balanceOf(aWhichPlayer);
        // Make sure user doesn't already have max exprience points 
        require(_bal < MAXEXP, "EXPToken (GainEXP): Already at Max(100).");
        // Make sure it doesn't go above capped possible points after _minting 
        require(_bal + iHowMuchGained <= MAXEXP, "EXPToken (Balance): Will go above Max(100).");
        // Mint tokens to the address
        _mint(aWhichPlayer, iHowMuchGained);
    }


    /// @dev reduceExperience function to remove exp from user's balance 
    /// Need to make sure, it doesn't go below 0 after deduction and user's balance isn't already zero
    /// This will stay disabled. If required in the future, enabled from ISoulbound
    // function reduceExperience(address looser_, uint256 lostAmount_) public {
    //     // Make sure only admins can call this function 
    //     require(_TokenAdmins[msg.sender] == true, "EXPToken (AccessControl): Not authorized.");
    //     // Make use of state variable only once if it's being used multiple times within function
    //     // In this case, balanceOf will access user's balance state var 
    //     uint256 _bal = balanceOf(looser_);
    //     // Make sure user's balance isn't already zero 
    //     require(_bal > 0, "EXPToken (Balance): Insufficient balance");
    //     // Make sure our calculation doesn't bring it below zero 
    //     // This calculation here will always throw "Integer Overflow" if _balance < lostAmount_
    //     // To temporarily mitigate unexpected throws, check is necessary 
    //     // require(_balance >= lostAmount_, "EXPToken (Balance): Can't go below Min(0).");
    //     // Burn given amount from user's balance 
    //     _burn(looser_, lostAmount_);
    // }


    // Set request parameters,
    // Once deployed, next task should be setting request parameters, which are then 
    // utilized while making the request for the random number
    // These request parameters are then passed to makeFullRequest 
    // on AirnodeRrpV0 to perform random number request 
    function setRequestParameters(
        address _airnode, 
        bytes32 _endpointIdUint256, 
        address _sponsorWallet) public onlyOwner 
    {
        // We need to make sure this function stays within reach of admin only 
        // Hence we try to include the ownable contract  
        aApiProviderAirnode = _airnode;
        btEndpointIdUint256 = _endpointIdUint256;
        aSponsorWallet = _sponsorWallet;
    }


    // We need a function that can request for randomness 
    function requestRandomEXPerienceForPlayer(address _whichPlayer) public onlyOwner {
        // Request for randomness for the player and save the interfaceID 
        // for later reference 
        // call makeFullRequest from AirnodeRrp contract with the details 
        // that we already have and hold on to request id for later 
        // fulfilment 
        // airnodeRrp is the address that we set within the constructor 
        bytes32 requestId = airnodeRrp.makeFullRequest(
            aApiProviderAirnode,         // Airnode's address where this request will be forwarded 
            btEndpointIdUint256,          // A path to uint256 for a single random uint256 number
            address(this),              // Sponsor, who is sponsoring this request 
            aSponsorWallet,              // Sponsor's wallet that will be calling the fulfill on AirnodeRrp
            address(this),              // Where the callback function for fulfillment resides 
            this.fulfillRandomNumberRequest.selector,   // which callback function to call upon fulfilment 
            ""                          // Any other paramters (usually the case when requesting Array(random array filled with different type values))
        );
        // we have the request id now, set it in the mapping
        mExpectingRequestWithIdToBeFulfilled[requestId] = true;
        // return our requestId so tht we can handle it within EXPToken contract
        // Once we receive the interface id, update mapping 
        mRequestIdToWhoRequested[requestId] = _whichPlayer;
        // So that later we can find this player and update their experience when 
        // we receive the callback from AirnodeRrp 
        // emit the event 
        emit RandomNumberRequested(requestId);
    }


    // For QRNG 
    // We will be using QRNGRequester contract
    // To generate random uint, we will use the function already implemented within that contract 
    // However, the callback function is listed here because we want to use 
    // the received results 
    function fulfillRandomNumberRequest(bytes32 _requestId, bytes calldata data) external onlyAirnodeRrp {
        // A callback function only accessible by AirnodeRrp
        // Check if we are acutally expecting a request to be fulfilled 
        require (
            mExpectingRequestWithIdToBeFulfilled[_requestId],
            "Unknown request ID");
        
        // Set the expectations back low
        mExpectingRequestWithIdToBeFulfilled[_requestId] = false;
        // Now on to the number that we received 
        uint256 qrngUint256 = abi.decode(data, (uint256));
        // Can we limit it to be within 100? But instead, we will first see 
        // what range it sends back 
        randomNumber = qrngUint256;
        // Emit the event stating we received the random number 
        emit RandomNumberReceived(_requestId, qrngUint256); 
    } 

}