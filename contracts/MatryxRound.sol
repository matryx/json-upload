pragma solidity ^0.4.13;

import './math/SafeMath.sol';

/**
 */
contract MatryxRound
{

    using SafeMath for uint256;

    address public owner;

    struct MatryxSubmission
    {
        address owner;
        address payout;
        bytes url; // Now store content within URL, will use Decentralized storage in the future
        uint256 rating;
        uint256 time;
        bool refunded;
    }

    bool closed;

    uint256 public bounty;
    uint256 public entryFee;

    //MatryxSubmission[] public submissions;
    address public subAddresses;
    mapping(address => MatryxSubmission) submissions;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public refundTime;
    uint256 public roundNumber;
    uint256 public numSubmissions;
    uint256 public totalRating = 0;

    function MatryxRound(uint256 _start, uint256 _end, uint256 _refund, uint256 _entryFee, uint256 _bounty, uint256 _roundNumber)
    {
        bounty = _bounty;
        entryFee = _entryFee;

        require(entryFee > 0);
        require(bounty > 0);

        startTime = _start;
        endTime = _end;
        refundTime = _refund;
        roundNumber = _roundNumber;
        numSubmissions = 0;

        require(startTime > now);
        require(startTime < endTime);
        require(refundTime > endTime);

        closed = false;

        //change ownership from calling contract to msg.sender
        owner = tx.origin;
    }

    function submit(address _submitter, bytes url, address payout) payable
    {
        require(closed == false);
        require(now > startTime);
        require(now < endTime);
        require(msg.value >= entryFee);

        MatryxSubmission memory submission;
        submission.owner = msg.sender;
        submission.payout = payout;
        submission.url = url;
        submission.rating = 0;
        submission.refunded = false;
        submission.time = now;
        //submissions.push(submission);
        submissions[tx.origin] = submission;

    }

    function rate(address _submitter, uint256 rating)
    {
        require(closed == false);
        require(now > endTime);
        require(now < refundTime);
        // We currently only late the bounty owner rate
        require(tx.origin == owner);

        submissions[_submitter].rating = rating;
    }

    function pay(address _submitter) {
        require(closed == true);
        require(submissions[_submitter].owner != 0x0);

        bounty = bounty.sub(msg.value);

        _submitter.send(msg.value);

    }

    function close(address winner, uint256 _totalRating)
    {
        require(closed == false);
        require(now > endTime);
        require(now < refundTime);
        // only the owner can close a round
        require(tx.origin == owner);

        // uint256 i = 0;
        // uint256 totalRating = 0;
        totalRating = _totalRating;

        // for (i = 0; i < submissions.length; i++)
        // {
        //     if (submissions[i].rating > 0)
        //     {
        //         totalRating = totalRating.add(submissions[i].rating);
        //     }
        // }

        // require(totalRating > 0);

        // for (i = 0; i < submissions.length; i++)
        // {
        //     // Payout fair share to submission
        //     // Compensation == Bounty * TotalRating / SubmissionRating
        //     if (submissions[i].rating > 0)
        //     {
        //         uint256 compensation = bounty.mul(totalRating).div(submissions[i].rating);
        //         // Send compasation to "submissions[i].payout"
        //     }
        // }
        closed = true;
    }

    function refund(address submitter)
    {

        //require(submissionIdx < submissions.length);
        //require(msg.sender == submissions[submissionIdx].owner);
        //require(submissions[submissionIdx].refunded == false);

        // Refund msg.sender of the "fee" + fair share of the bounty
        //uint256 compensation = bounty.div(submissions.length).add(entryFee);
        // Send compensation to "submissions[submissionIdx].payout"
        //submissions[submissionIdx].refunded = true;
    }

    function getStart() external constant returns (uint256) {
        return startTime;
    }

    function getEnd() external constant returns (uint256) {
        return endTime;
    }

    function getRefundTime() external constant returns (uint256) {
        return refundTime;
    }

    function getSubmitter() external constant returns (address) {
        return submissions[tx.origin].owner;
    }

    function getRating(address _submitter) external constant returns (uint256) {
        return submissions[_submitter].rating;
    }

    function getTotalRating() external constant returns (uint256) {
        return totalRating;
    }
}
