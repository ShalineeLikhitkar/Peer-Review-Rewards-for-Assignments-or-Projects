// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PeerReviewRewards {

    address public owner; 
    uint public totalRewardsDistributed;
    mapping(address => uint) public userRewards;
    mapping(uint => Review) public reviews;
    mapping(uint => address) public assignments;
    uint public reviewIdCounter;

    struct Review {
        address reviewer;
        uint assignmentId;
        uint rating; // Rating out of 5
        string comment;
    }

    event ReviewSubmitted(address indexed reviewer, uint assignmentId, uint rating, string comment, uint reviewId);
    event RewardClaimed(address indexed user, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyReviewer(uint reviewId) {
        require(msg.sender == reviews[reviewId].reviewer, "Only the reviewer can claim rewards for this review");
        _;
    }

    constructor() {
        owner = msg.sender;
        reviewIdCounter = 1;
    }

    // Function to submit a review for an assignment or project
    function submitReview(uint assignmentId, uint rating, string memory comment) public {
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");

        // Create a new review
        reviews[reviewIdCounter] = Review({
            reviewer: msg.sender,
            assignmentId: assignmentId,
            rating: rating,
            comment: comment
        });

        assignments[assignmentId] = msg.sender; // Assign the assignment to the reviewer
        emit ReviewSubmitted(msg.sender, assignmentId, rating, comment, reviewIdCounter);
        reviewIdCounter++;
    }

    // Function to calculate reward based on review rating
    function calculateReward(uint reviewId) public view returns (uint) {
        uint rating = reviews[reviewId].rating;
        if (rating == 5) {
            return 0.05 ether;  // Highest reward for a rating of 5
        } else if (rating == 4) {
            return 0.03 ether;  // Moderate reward for a rating of 4
        } else if (rating == 3) {
            return 0.01 ether;  // Small reward for a rating of 3
        } else {
            return 0;  // No reward for rating below 3
        }
    }

    // Function to claim reward for a review
    function claimReward(uint reviewId) public onlyReviewer(reviewId) {
        uint reward = calculateReward(reviewId);
        require(reward > 0, "No reward available for this review");
        userRewards[msg.sender] += reward;
        totalRewardsDistributed += reward;
        emit RewardClaimed(msg.sender, reward);
    }

    // Function to withdraw the earned rewards
    function withdraw() public {
        uint reward = userRewards[msg.sender];
        require(reward > 0, "No rewards to withdraw");
        userRewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
    }

    // Fallback function to accept Ether
    receive() external payable {}

    // View function to check user rewards
    function checkUserRewards(address user) public view returns (uint) {
        return userRewards[user];
    }

    // View function to check the total rewards distributed
    function checkTotalRewards() public view returns (uint) {
        return totalRewardsDistributed;
    }
}
