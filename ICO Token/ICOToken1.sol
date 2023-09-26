// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ICOToken is ERC20 {
    constructor() ERC20("CyberToken", "CYT") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function transferToken(
        address from,
        address to,
        uint256 noOfTokens
    ) public {
        _transfer(from, to, noOfTokens);
    }
}

contract CreateNewICO is ICOToken {
    address public Admin;
    address public DeveloperAddress;

    address public CommunityMemberAddress1;
    address public CommunityMemberAddress2;
    address public CommunityMemberAddress3;
    address public CommunityMemberAddress4;
    address public CommunityMemberAddress5;

    address public InvestorAddress;

    uint256 private TotalSupply = 10000000;
    uint256 public initialprice = 100;

    ICOToken private icotoken;

    struct TokenBuyers {
        address buyerAddress;
        uint256 noOfTokens;
        uint256 amount;
    }

    mapping(address => TokenBuyers) public PublicHoldedTokens;

    event FundTransfer(address investor, address owner, string message);

    constructor(
        address tokenAddress,
        address developerAddress,
        address communityMemberAddress1,
        address communityMemberAddress2,
        address communityMemberAddress3,
        address communityMemberAddress4,
        address communityMemberAddress5,
        address investorAddress
    ) {
        icotoken = ICOToken(tokenAddress);
        Admin = msg.sender;
        DeveloperAddress = developerAddress;
        CommunityMemberAddress1 = communityMemberAddress1;
        CommunityMemberAddress2 = communityMemberAddress2;
        CommunityMemberAddress3 = communityMemberAddress3;
        CommunityMemberAddress4 = communityMemberAddress4;
        CommunityMemberAddress5 = communityMemberAddress5;
        InvestorAddress = investorAddress;

        icotoken.mint(address(this), TotalSupply);
        uint256 developerHoldTokens = (icotoken.totalSupply() * 10) / 100;
        uint256 CommunityHoldTokens = (icotoken.totalSupply() * 60) / 100;
        uint256 HoldTokenByPerMember = CommunityHoldTokens / 5;
        uint256 InvestorsHoldTokens = (icotoken.totalSupply() * 20) / 100;
        icotoken.transfer(CommunityMemberAddress1, HoldTokenByPerMember);
        icotoken.transfer(CommunityMemberAddress2, HoldTokenByPerMember);
        icotoken.transfer(CommunityMemberAddress3, HoldTokenByPerMember);
        icotoken.transfer(CommunityMemberAddress4, HoldTokenByPerMember);
        icotoken.transfer(CommunityMemberAddress5, HoldTokenByPerMember);
        icotoken.transfer(DeveloperAddress, developerHoldTokens);
        icotoken.transfer(InvestorAddress, InvestorsHoldTokens);
    }

    modifier onlyAdmin() {
        require(msg.sender == Admin, "Only admin can perform this work.");
        _;
    }

    function setPrice(uint256 price) public onlyAdmin returns (uint256) {
        initialprice = price;
        return initialprice;
    }

    function buyToken(uint256 noOfTokens) external payable {
        require(
            msg.sender != DeveloperAddress &&
                msg.sender != Admin &&
                msg.sender != CommunityMemberAddress1 &&
                msg.sender != CommunityMemberAddress2 &&
                msg.sender != CommunityMemberAddress3 &&
                msg.sender != CommunityMemberAddress4 &&
                msg.sender != CommunityMemberAddress5 &&
                msg.sender != InvestorAddress,
            "Community members, developer and investor cannot buy public offering tokens."
        );
        require(noOfTokens > 0, "Number of tokens are greater than zero.");
        tranferMoneyToBuyTokens(noOfTokens);
        icotoken.transferToken(address(this), msg.sender, noOfTokens);
    }

    function tranferMoneyToBuyTokens(uint256 noOfTokens) public payable {
        require(
            msg.value == noOfTokens * initialprice,
            "Value = noOfTokens * initialprice."
        );
        TokenBuyers storage token = PublicHoldedTokens[msg.sender];
        token.buyerAddress = msg.sender;
        token.amount += msg.value;
        token.noOfTokens += noOfTokens;
        uint256 adminAmount = (msg.value * 90) / 100;
        uint256 communityAmount = (msg.value * 10) / 100;
        uint256 perMemberAmount = communityAmount / 5;

        payable(Admin).transfer(adminAmount);
        payable(CommunityMemberAddress1).transfer(perMemberAmount);
        payable(CommunityMemberAddress2).transfer(perMemberAmount);
        payable(CommunityMemberAddress3).transfer(perMemberAmount);
        payable(CommunityMemberAddress4).transfer(perMemberAmount);
        payable(CommunityMemberAddress5).transfer(perMemberAmount);
    }
}
