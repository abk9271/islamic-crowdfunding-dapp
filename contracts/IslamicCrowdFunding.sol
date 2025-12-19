// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

contract IslamicCrowdFunding {
    struct Contributor {
        address addr;
        uint256 amount;
    }
    struct ProjectInfo {
        string name;
        string description;
        address creator;
        uint256 deadline;
        uint256 goal;
        uint256 totalContributed;
        uint256 profitPool;
        bool isClosed;
    }
    ProjectInfo[] public projects;
    //mapping (ProjectInfo => string) public mappedProjects;

    mapping (address => uint256) public contributions;
    Contributor[] public contributors; //Created an array of Contributors
    // created the mapping of the contributors, so each contributor can be accessed by their address
                  // has an array of Contributor[] (a Contributor[] is an array of the Contributor)
                // a Contributor is a user-defined type, grouping address and amount contributed

    mapping (address => Contributor) public addressToContributor;
    mapping (uint => Contributor[]) public projectContributors;
    mapping (uint => mapping (address => uint256)) public projectContributions;
    
    uint256 public totalBalance;

    function createProject(
        string memory _name,
        string memory _description,
        uint256 _goal
    ) external {
        ProjectInfo memory newPI = ProjectInfo({creator: msg.sender,
            name: _name,
            description: _description,
            goal: _goal, deadline:
            block.timestamp + 90 days,
            totalContributed: 0,
            profitPool: 0,
            isClosed: false});
        projects.push(newPI);
    }



    function contribute(uint projectId) public payable{
        require(msg.value > 0, "You can't deposit 0 ETH");
        require(msg.value < projects[projectId].goal, "If you deposit Goal is going to be surpassed");
        projectContributions[projectId][msg.sender] += msg.value; 
        totalBalance += msg.value;
        projects[projectId].totalContributed += msg.value;

        // checks if the msg.sender had sent money b4
        bool isNewContributor = true;
        
        for (uint i=0; i<projectContributors[projectId].length; i++) {
            if (projectContributions[projectId][i].addr == msg.sender) {
                isNewContributor = false;
                break;
            }
        }
        if (isNewContributor) {
        projectContributors[projectId].push(addContributors(msg.sender, msg.value));
        }
    }
    
    function withdrawFunds() public {
        if (block.timestamp < unlockTime[msg.sender]) {
            revert ("Profit still locked");
        
            contributions[msg.sender] -= contributions[msg.sender];
            projectContributions[projectId][msg.sender] -= projectContributions[projectId][msg.sender]; 
            totalBalance -= contributions[msg.sender];
        }
    }
    function viewContribution() public view returns (uint) {
        return projectContributions[projectId][msg.sender];
    }
    function viewTotalBalance() public view returns (uint) {
        return totalBalance;
    }

    function addContributors(address addr_name, uint256 amount_contributed) private returns (Contributor) {
        Contributor memory newContributor = Contributor(addr_name, amount_contributed);
        contributors.push(newContributor);
        addressToContributor[addr_name] = newContributor;
        return newContributor;
    }

    function addProfit(uint projectId) external payable {
        require(msg.sender == projects[projectId].creator, "Only the Creator can add Profit");
        //(bool sent, bytes memory data) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        projects[projectId].profitPool += msg.value;
    }

    function distributeProfit(uint projectId) external payable {
        uint256 share = (projects[projectId].profitPool)/projects[projectId].totalContributed

        for (uint i=0; i<projectContributors[projectId].length; i++) {
                //looping through the contributors in project1/2/3 
  
            address memberAddress = projectContributors[projectId][i].addr; // assigned the address to the var. memberAddress 
            uint amount = projectContributors[projectId][memberAddress]; // assign the amount a user contributed to the variable amount
            uint share = (amount * projects[projectId].profitPool)/projects[projectId].totalContributed; // calculating each user profit

            (bool success) = payable(memberAddress).call{value: share}("");
            require(success, "Failed to distribute Profit");
        }
        projects[projectId].totalContributed = 0;
    }
}

