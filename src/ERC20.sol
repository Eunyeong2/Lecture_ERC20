//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // 0.8 대 컴파일러 모두 가능

contract ERC20 {

    mapping(address => uint256) private balances; 
    mapping(address => mapping(address => uint256)) private allowances; //보내는 주소, 받는 주소, 허용량 필요
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimal; // 18, 6
    // public으로 해도 상관 없는데, 보안 때문에 일반적으로 private로 구현

    constructor() {
        _name = "DREAM";
        _symbol = "DRM";
        _decimal = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
    }

    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimal;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    function transfer(address _to, address _from, uint256 _value) external returns (bool success) {
        //to address가 zero면 토큰이 묶이기 때문에 제한을 해줘야 함.
        require(msg.sender != address(0)); //require에 실패하면 revert -> gas 필요함. 그렇기 때문에 가장 앞 쪽에 넣는 게 좋음
        // msg.sender를 0으로 변조하여 전송할 수 있는 공격이 있기 때문에 막아주는 목적
        require(_to != address(0));
        //return 상태(3개) : ok, revert, ? / 이유 없이 죽으면 gas consume. revert가 완료되면 사용하지 않은 gas는 돌려줌. 
        require(balances[msg.sender] >= _value, "Value exceeds balance");
        
        unchecked {
            //under, overflow 가능성이 없을 때 unchecked 하여 가스 줄이기 (8 version 이상에서만. 이하에서는 safemath?)
            balances[_to] += _value;
            balances[_from] -= _value;
        }

        emit Transfer(msg.sender, _to, _value);  //event
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        //to address가 zero면 토큰이 묶이기 때문에 제한을 해줘야 함.
        require(msg.sender != address(0)); //require에 실패하면 revert -> gas 필요함. 그렇기 때문에 가장 앞 쪽에 넣는 게 좋음
        // msg.sender를 0으로 변조하여 전송할 수 있는 공격이 있기 때문에 막아주는 목적
        //return 상태(3개) : ok, revert, ? / 이유 없이 죽으면 gas consume. revert가 완료되면 사용하지 않은 gas는 돌려줌. 
        require(balances[msg.sender] >= _value, "Value exceeds balance");
        require(_to != address(0));

        
        unchecked {
            //under, overflow 가능성이 없을 때 unchecked 하여 가스 줄이기 (8 version 이상에서만. 이하에서는 safemath?)
            balances[_to] += _value;
            balances[msg.sender] -= _value;
        }

        emit Transfer(msg.sender, _to, _value);  //event
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success){
        //to address가 zero면 토큰이 묶이기 때문에 제한을 해줘야 함.
        require(msg.sender != address(0)); //require에 실패하면 revert -> gas 필요함. 그렇기 때문에 가장 앞 쪽에 넣는 게 좋음
        // msg.sender를 0으로 변조하여 전송할 수 있는 공격이 있기 때문에 막아주는 목적
        require(_to != address(0));
        //return 상태(3개) : ok, revert, ? / 이유 없이 죽으면 gas consume. revert가 완료되면 사용하지 않은 gas는 돌려줌. 
        require(balances[_from] >= _value, "Value exceeds balance"); //value는 from이 to한테 보내는 거기 때문에 balances[_from]의 value를 검사해야 함.

        uint256 curretnAllowance = allowance(_from, msg.sender);
        //if (curretnAllowance)
        require(curretnAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }
        require(balances[_from] >= _value);

        unchecked {
            balances[_to] += _value;
            balances[_from] -= _value;
        }

        emit Transfer(_from, _to, _value);  //event

        return true;
    }

    function approve(address _to, uint256 _value) public returns (bool success){
        allowances[msg.sender][_to] = _value;
        if (allowances[msg.sender][_to] > 0){
            return true;
        } else{
            return false;
        }
    }

    function allowance(address _owner, address _spender) public returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    function _mint(address _from, uint256 _value) public {
        require(_from != address(0), "Non exist address");
        require(balances[_from] + _value <= type(uint256).max);
        balances[_from] += _value;
        _totalSupply += _value;
    }

    function _burn(address _to, uint256 _value) public {
        require(_to != address(0));
        require(balances[_to] - _value >= 0 );
        balances[_to] -= _value;
        _totalSupply -= _value;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);
}