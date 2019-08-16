pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Crowdfund {
    using SafeMath for uint;

    /** Events **/

    // Emitted when a new Project is created.
    event ProjectCreated(
        uint projectId,
        address creator,
        string title,
        string description,
        uint fundraisingDeadline
    );

    // Emitted when a new Milestone is created.
    event MilestoneCreated(
        uint milestoneId,
        address creator,
        string deliverable,
        uint cost,
        uint daysToComplete
    );

    // Emitted when a new Vote is created.
    event VoteCreated(
        uint voteId,
        uint pollsClose
    );

    // Emitted when project funding is received and escrowed.
    event FundingReceived(address contributor, uint amount, uint currentTotal);
    
    // Emitted when project creator is paid out for a milestone.
    event CreatorPaid(address recipient, uint amount);

    /** Project data structures **/

    enum ProjectState {
        Fundraising,
        Expired,
        Successful
    }

    struct Project {
        address payable creator;
        string title;
        string description;
        uint fundraisingDeadline;
        uint completionDeadline;
        uint goalAmount; // required to reach at least this much, else everyone gets refund
        uint currentBalance;
        ProjectState state;
        mapping (address => uint) contributions;
    }

    Project[] public projects;
    uint public projectCount = 0;

    /** Milestone data structures **/

    struct Milestone {
        uint projectId;
        address payable creator;
        string deliverable;
        uint cost;
        uint daysToComplete;
    }

    Milestone[] public milestones;

    // Map project id to milestone ids.
    mapping (uint => uint[]) public projectMilestones;
    // Map project id to milestone counter.
    mapping (uint => uint) public projectMilestoneCount;

    /** Vote data structures **/

    struct Vote {
        uint milestoneId;
        uint yay;
        uint nay;
        uint pollsClose;
    }

    Vote[] public votes;

    // Map milestone id to vote id.
    mapping (uint => uint) public milestoneVote;

    /** Modifiers **/

    // Check current project state.
    modifier inState(uint _projectId, ProjectState _state) {
        require(projects[_projectId].state == _state);
        _;
    }

    // Check if the function caller is the project creator.
    modifier isCreator(uint _projectId) {
        require(msg.sender == projects[_projectId].creator);
        _;
    }

    // Check if the function caller is NOT the project creator.
    modifier isNotCreator(uint _projectId) {
        require(msg.sender != projects[_projectId].creator);
        _;
    }

    // Check if the function caller is a project contributor.
    modifier onlyContributor(uint _voteId) {
        require(projects[ // Get the project
          milestones[ // which has the milestone
            milestoneVote[_voteId] // which has this vote
          ].projectId
        ].contributions[msg.sender] > 0); // and check if msg.sender is a contributor
        _;
    }

    /** Project business logic **/

    /** @dev Create a new project.
      * @param _title Title of the project to be created
      * @param _description Brief description about the project
      */
    function createProject(
        string calldata _title,
        string calldata _description,
        uint _daysToFundraise
    ) external {
        uint _fundraisingDeadline = now.add(_daysToFundraise.mul(1 days));

        Project memory _newProject = Project(
            msg.sender,
            _title,
            _description,
            _fundraisingDeadline,
            0, // completionDeadline
            0, // goalAmount
            0, // currentBalance
            ProjectState.Fundraising
        );

        uint _projectId = projects.push(_newProject) - 1;
        projectCount++;

        emit ProjectCreated(
            _projectId,
            msg.sender,
            _title,
            _description,
            _fundraisingDeadline
        );
    }

    /** @dev Fund a project.
      */
    function contribute(uint _projectId)
        external
        isNotCreator(_projectId)
        inState(_projectId, ProjectState.Fundraising)
        payable
    {
        // Update the amount this user has contributed to the specified project.
        projects[_projectId].contributions[msg.sender] =
            projects[_projectId].contributions[msg.sender].add(msg.value);

        // Update the balance of the specified project.
        projects[_projectId].currentBalance =
            projects[_projectId].currentBalance.add(msg.value);

        emit FundingReceived(msg.sender, msg.value, projects[_projectId].currentBalance);

        checkIfFundingComplete(_projectId);
    }

    function getContributions(uint _projectId) public view returns (uint) {
        return projects[_projectId].contributions[msg.sender];
    }

    /** @dev Change the project state depending on conditions.
      */
    function checkIfFundingComplete(uint _projectId) public {
        if (projects[_projectId].currentBalance >= projects[_projectId].goalAmount) {
            projects[_projectId].state = ProjectState.Successful;
            payOut(_projectId);
        }
        projects[_projectId].completionDeadline = now.add(milestones[projectMilestones[_projectId][0]].daysToComplete);
    }

    /** @dev Give the received funds to project starter.
      */
    function payOut(uint _projectId) internal inState(_projectId, ProjectState.Successful) returns (bool) {
        uint _totalRaised = projects[_projectId].currentBalance;

        if (projects[_projectId].creator.send(_totalRaised)) {
            emit CreatorPaid(projects[_projectId].creator, _totalRaised);
            projects[_projectId].currentBalance = 0;
            return true;
        }

        return false;
    }

    /** @dev Retrieve donated amount when a project expires.
      */
    function getRefund(uint _projectId) public inState(_projectId, ProjectState.Expired) returns (bool) {
        require(projects[_projectId].contributions[msg.sender] > 0);

        uint _amountToRefund = projects[_projectId].contributions[msg.sender];
        projects[_projectId].contributions[msg.sender] = 0;

        if (!msg.sender.send(_amountToRefund)) {
            projects[_projectId].contributions[msg.sender] = _amountToRefund;
            return false;
        } else {
            projects[_projectId].currentBalance =
                projects[_projectId].currentBalance.sub(_amountToRefund);
        }

        return true;
    }

    /** Milestone business logic **/

    /** @dev Add a milestone to a project.
      * @param _cost Milestone cost in Wei
      * @param _daysToComplete Milestone completion period
      */      
    function createMilestone(
        uint _projectId,
        string calldata _deliverable,
        uint _cost,
        uint _daysToComplete
    ) external {
        Milestone memory _milestone = Milestone(
            _projectId,
            msg.sender,
            _deliverable,
            _cost,
            _daysToComplete.mul(1 days)
        );

        uint _milestoneId = milestones.push(_milestone) - 1;
        projectMilestones[_projectId].push(_milestoneId);
        projectMilestoneCount[_projectId]++;
        projects[_projectId].goalAmount += _cost;

        emit MilestoneCreated(
            _milestoneId,
            msg.sender,
            _deliverable,
            _cost,
            _daysToComplete
        );
    }

    /** Vote business logic **/

    function createVote(uint _milestoneId, uint votingPeriod) external {
        // Add a week grace period for voting.
        uint _pollsClose = now.add(votingPeriod.mul(1 days)).add(7 days);
        Vote memory _vote = Vote(
            _milestoneId,
            0,
            0,
            _pollsClose
        );

        uint _voteId = votes.push(_vote) - 1;
        milestoneVote[_milestoneId] = _voteId;

        emit VoteCreated(
            _voteId,
            _pollsClose
        );
    }

    function voteYay(uint _voteId) onlyContributor(_voteId) public {
        votes[_voteId].yay++;
        checkIfFundingApproved(_voteId);
    }

    function voteNay(uint _voteId) onlyContributor(_voteId) public {
        votes[_voteId].nay++;
        checkIfFundingApproved(_voteId);
    }

    function checkIfFundingApproved(uint _voteId) private {
        // TODO: After each vote, see if we've reached a super majority or if the vote is expired
    }
}
