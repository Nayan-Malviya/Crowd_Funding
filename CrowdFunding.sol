// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
contract CrowdFunding{
    mapping (address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noofContributors;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVooters;
        mapping(address=>bool)voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=_deadline;
        manager=msg.sender;
        minimumContribution=100 wei;
    }
    function sendEth() public payable{
        require(deadline>block.timestamp,"DeadLine has passed");
        require(msg.value>=minimumContribution,"Minimum Contribution does not met");
        if(contributors[msg.sender]==0){
            noofContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public payable{
        require(block.timestamp>deadline && target>raisedAmount,"You are not eligible for Refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only Manager can access this");
        _;
    }
    function createReq(string memory _description,address payable _recepient,uint _value) public onlyManager(){
        Request storage newrequest=requests[numRequests];
        numRequests++;
        newrequest.description=_description;
        newrequest.recipient=_recepient;
        newrequest.value=_value;
        newrequest.completed=false;
        newrequest.noOfVooters=0;
    }
    function voteRequest(uint request_no)public{
        require(contributors[msg.sender]>0,"You must be Contributor");
        Request storage thisrequest=requests[request_no];
        require(thisrequest.voters[msg.sender]==false,"you have already voted");
        thisrequest.voters[msg.sender]==true;
        thisrequest.noOfVooters++;
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target,"Enough Money is not Raisedof");
        Request storage thisrequest=requests[_requestNo];
        require(thisrequest.completed==false,"Payment is aleary done");
        require(thisrequest.noOfVooters>=noofContributors/2,"Majority is not in Favour");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed==true;
    }
}
