// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IERC20.sol';

contract ProtocolLiquidity {
  address public owner;
  mapping(address => uint256) public balances;
  mapping(address => bool) public approvedTokens;

  event TokensSwapped(
    address indexed fromToken,
    address indexed toToken,
    uint256 amount,
    uint256 receivedAmount
  );
  event TokenProportionsChanged(address[] tokens, uint256[] proportions);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, 'Only contract owner can call this function');
    _;
  }

  function addApprovedToken(address _tokenAddress) external onlyOwner {
    require(_tokenAddress != address(0), 'Invalid token address');
    require(!approvedTokens[_tokenAddress], 'Token already approved');

    approvedTokens[_tokenAddress] = true;
  }

  function removeApprovedToken(address _tokenAddress) external onlyOwner {
    require(approvedTokens[_tokenAddress], 'Token is not approved');
    delete approvedTokens[_tokenAddress];
  }

  function swapTokens(
    address _fromToken,
    address _toToken,
    uint256 _amount
  ) external {
    require(
      approvedTokens[_fromToken] && approvedTokens[_toToken],
      'Tokens not approved'
    );

    // Get the current balances of the tokens in the pool
    uint256 fromTokenBalance = balances[_fromToken];
    uint256 toTokenBalance = balances[_toToken];

    // Calculate the amount of tokens to receive based on the constant product formula
    uint256 toTokenAmount = (toTokenBalance * _amount) / fromTokenBalance;

    // Update the balances in the pool
    balances[_fromToken] -= _amount;
    balances[_toToken] += toTokenAmount;

    // Perform the token transfer
    IERC20(_fromToken).transferFrom(msg.sender, address(this), _amount);
    IERC20(_toToken).transfer(msg.sender, toTokenAmount);

    // Emit an event to track the swap details
    emit TokensSwapped(_fromToken, _toToken, _amount, toTokenAmount);
  }

  function changeTokenProportions(
    address[] memory _tokens,
    uint256[] memory _proportions
  ) external onlyOwner {
    require(_tokens.length == _proportions.length, 'Invalid input');

    uint256 totalProportion;

    for (uint256 i = 0; i < _tokens.length; i++) {
      require(approvedTokens[_tokens[i]], 'Token not approved');
      totalProportion += _proportions[i];
    }

    require(totalProportion == 100, 'Proportions must add up to 100');

    // Update the token proportions
    for (uint256 i = 0; i < _tokens.length; i++) {
      approvedTokens[_tokens[i]].proportion = _proportions[i];
    }

    emit TokenProportionsChanged(_tokens, _proportions);
  }

  function provideLiquidity() external payable {
    require(msg.value > 0, 'ETH amount must be greater than zero');

    uint256 ethAmount = msg.value;
    uint256 totalProportion;

    for (uint256 i = 0; i < tokens.length; i++) {
      require(
        approvedTokens[tokens[i]].tokenAddress != address(0),
        'Token not approved'
      );

      uint256 tokenAmount = (ethAmount * approvedTokens[tokens[i]].proportion) /
        100;
      IERC20(tokens[i]).transferFrom(msg.sender, address(this), tokenAmount);

      totalProportion += approvedTokens[tokens[i]].proportion;
    }

    require(totalProportion == 100, 'Token proportions do not add up to 100');
  }

  function removeLiquidity(address _toToken, uint256 _sbtAmount) external {
    require(
      approvedTokens[_toToken].tokenAddress != address(0),
      'Token not approved'
    );

    uint256 totalSupply = calculateTotalPoolBalance();
    uint256 toTokenBalance = balances[_toToken];
    uint256 toTokenAmount = (toTokenBalance * _sbtAmount) / totalSupply;

    // Update balances
    balances[_toToken] -= toTokenAmount;

    // Transfer tokens to the user
    IERC20(_toToken).transfer(msg.sender, toTokenAmount);
  }

  function calculateTotalPoolBalance() public view returns (uint256) {
    uint256 totalBalance;

    for (uint256 i = 0; i < tokens.length; i++) {
      totalBalance += balances[tokens[i]];
    }

    return totalBalance;
  }

  function totalSupply() external view returns (uint256) {
    return calculateTotalPoolBalance();
  }
}
