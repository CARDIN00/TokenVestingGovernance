// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount)external returns (bool);
    function balanceOf(address user)external returns (uint);
}

contract TokenVesting{
    IERC20 public token;
    address public Owner;

    struct vestingSchedule{
        uint totalAmount;// total tokens to be vested
        uint releasedAmount;//amount already released
        uint startTime;// vesting start
        uint cliffDuration;
        uint vestingDuration;// total vesting duration
    }

    mapping (address => vestingSchedule) public beneficiaries;

    modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }

    constructor(address _token){
        require(_token != address(0));
        token = IERC20(_token);
        Owner = msg.sender;
    }

    // logs
    event releaseToken(address indexed beneficiary, uint256 amount);

    // FUNCTIONS
    function addBenificiary(
        address _benificiary,
        uint _totalAmount,
        uint _startTime,
        uint _cliffTime,
        uint _vestingTime
    )
    external onlyOwner{
        require(_benificiary != address(0),"invalid Address");
        require(_totalAmount >0,"allocatoin must be positive");
        require(_vestingTime >_cliffTime,"vesting time must exceede cliff time");
        require(beneficiaries[_benificiary].totalAmount == 0,"vesting schedule exists");
        beneficiaries[_benificiary] = vestingSchedule({
            totalAmount :_totalAmount,
            startTime :_startTime,
            cliffDuration : _cliffTime,
            vestingDuration :_vestingTime,
            releasedAmount : 0
        });
    }

    function calculateVestedTokens(address _benificiarry)public view returns (uint){
        vestingSchedule memory schedule =beneficiaries[_benificiarry];
        require(schedule.totalAmount > 0 , "No schedule availabe");

        uint currentTime = block.timestamp;

        if(currentTime < schedule.startTime + schedule.cliffDuration){
            return  0;
        }
        if(currentTime >= schedule.startTime + schedule.vestingDuration){
            return  schedule.totalAmount - schedule.releasedAmount;
        }

        uint elapsedTime =currentTime - schedule.startTime;
        uint totalVested = (schedule.totalAmount * elapsedTime) / schedule.vestingDuration;
        //the tokens that are released but not yet recieved
        return totalVested - schedule.releasedAmount;

    }

    //release the vested tokens that are not yet released
    function release()external {
        vestingSchedule storage schedule = beneficiaries[msg.sender];
        require(schedule.totalAmount > 0,"no schedule found");

        uint vestedTokens = calculateVestedTokens(msg.sender);
        require(vestedTokens >0,"no tokens for release");
        schedule.releasedAmount += vestedTokens;
        require(token.transfer(msg.sender, vestedTokens),"transfer failed");

        emit releaseToken(msg.sender, vestedTokens);
    }
}