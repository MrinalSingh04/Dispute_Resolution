// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DisputeResolution {
    enum DealStatus {
        Active,
        Disputed,
        Resolved
    }
    enum VoteOption {
        None,
        PartyA,
        PartyB
    }

    struct Deal {
        address partyA;
        address partyB;
        uint256 amount;
        DealStatus status;
        address[] jurors;
        mapping(address => VoteOption) votes;
        uint8 votesA;
        uint8 votesB;
        address winner;
    }

    uint256 public dealCount;
    uint8 public constant NUM_JURORS = 3;
    mapping(uint256 => Deal) private deals;
    address[] public jurorPool;

    event DealCreated(
        uint256 dealId,
        address partyA,
        address partyB,
        uint256 amount
    );
    event DisputeStarted(uint256 dealId);
    event JurorsSelected(uint256 dealId, address[] jurors);
    event Voted(uint256 dealId, address juror, VoteOption vote);
    event DisputeResolved(uint256 dealId, address winner);

    modifier onlyParties(uint256 dealId) {
        Deal storage deal = deals[dealId];
        require(
            msg.sender == deal.partyA || msg.sender == deal.partyB,
            "Not a deal party"
        );
        _;
    }

    function registerAsJuror() external {
        jurorPool.push(msg.sender);
    }

    function createDeal(address _partyB) external payable returns (uint256) {
        require(msg.value > 0, "Funds required");
        dealCount++;
        Deal storage deal = deals[dealCount];
        deal.partyA = msg.sender;
        deal.partyB = _partyB;
        deal.amount = msg.value;
        deal.status = DealStatus.Active;

        emit DealCreated(dealCount, msg.sender, _partyB, msg.value);
        return dealCount;
    }

    function startDispute(uint256 dealId) external onlyParties(dealId) {
        Deal storage deal = deals[dealId];
        require(deal.status == DealStatus.Active, "Invalid status");
        deal.status = DealStatus.Disputed;

        _selectJurors(dealId);
        emit DisputeStarted(dealId);
    }

    function _selectJurors(uint256 dealId) internal {
        require(jurorPool.length >= NUM_JURORS, "Not enough jurors");
        Deal storage deal = deals[dealId];

        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, dealId)
            )
        );
        uint256 index;
        for (uint8 i = 0; i < NUM_JURORS; i++) {
            index = uint256(keccak256(abi.encode(seed, i))) % jurorPool.length;
            address juror = jurorPool[index];
            for (uint8 j = 0; j < i; j++) {
                require(deal.jurors[j] != juror, "Duplicate juror");
            }
            deal.jurors.push(juror);
        }

        emit JurorsSelected(dealId, deal.jurors);
    }

    function vote(uint256 dealId, VoteOption _vote) external {
        Deal storage deal = deals[dealId];
        require(deal.status == DealStatus.Disputed, "Not disputed");
        require(
            _vote == VoteOption.PartyA || _vote == VoteOption.PartyB,
            "Invalid vote"
        );

        bool isJuror = false;
        for (uint8 i = 0; i < deal.jurors.length; i++) {
            if (deal.jurors[i] == msg.sender) {
                isJuror = true;
                break;
            }
        }
        require(isJuror, "Not a juror");
        require(deal.votes[msg.sender] == VoteOption.None, "Already voted");

        deal.votes[msg.sender] = _vote;
        if (_vote == VoteOption.PartyA) {
            deal.votesA++;
        } else {
            deal.votesB++;
        }

        emit Voted(dealId, msg.sender, _vote);

        if (deal.votesA + deal.votesB == NUM_JURORS) {
            _resolveDispute(dealId);
        }
    }

    function _resolveDispute(uint256 dealId) internal {
        Deal storage deal = deals[dealId];
        require(deal.status == DealStatus.Disputed, "Not disputed");

        deal.status = DealStatus.Resolved;

        if (deal.votesA > deal.votesB) {
            payable(deal.partyA).transfer(deal.amount);
            deal.winner = deal.partyA;
        } else {
            payable(deal.partyB).transfer(deal.amount);
            deal.winner = deal.partyB;
        }

        emit DisputeResolved(dealId, deal.winner);
    }

    // View functions
    function getDeal(
        uint256 dealId
    )
        external
        view
        returns (
            address partyA,
            address partyB,
            uint256 amount,
            DealStatus status,
            address winner,
            address[] memory jurors
        )
    {
        Deal storage deal = deals[dealId];
        return (
            deal.partyA,
            deal.partyB,
            deal.amount,
            deal.status,
            deal.winner,
            deal.jurors
        );
    }

    function getVote(
        uint256 dealId,
        address juror
    ) external view returns (VoteOption) {
        return deals[dealId].votes[juror];
    }

    function getJurorPool() external view returns (address[] memory) {
        return jurorPool;
    }
}
