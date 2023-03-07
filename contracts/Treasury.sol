// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury {
    address public DAO;
    address public SDAO;
    address public WETH;
    uint256 public balance;

    UniswapV2Router public router;
    address public liquidityPair;

    constructor(address _DAO, address _SDAO, address _WETH, UniswapV2Router _router) {
        DAO = _DAO;
        SDAO = _SDAO;
        WETH = _WETH;
        router = _router;
        liquidityPair = router.getPair(SDAO, WETH);
        require(liquidityPair != address(0), "Treasury: INVALID_PAIR");
    }

    function deposit(uint256 amount) external {
        require(IERC20(SDAO).transferFrom(msg.sender, address(this), amount), "Treasury: TRANSFER_FAILED");
        balance += amount;
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == DAO, "Treasury: ACCESS_DENIED");
        require(balance >= amount, "Treasury: INSUFFICIENT_BALANCE");
        require(IERC20(SDAO).transfer(DAO, amount), "Treasury: TRANSFER_FAILED");
        balance -= amount;
    }

    function addLiquidity(uint256 amount) external {
        require(IERC20(SDAO).transferFrom(msg.sender, address(this), amount), "Treasury: TRANSFER_FAILED");
        uint256 ethAmount = address(this).balance;
        require(ethAmount > 0, "Treasury: INSUFFICIENT_ETH_BALANCE");
        IERC20(SDAO).approve(address(router), amount);
        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidityETH{value: ethAmount}(
            SDAO,
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
        balance += amountA;
        require(IERC20(SDAO).transfer(DAO, amountA), "Treasury: TRANSFER_FAILED");
        require(IERC20(liquidityPair).transfer(DAO, liquidity), "Treasury: TRANSFER_FAILED");
    }

    function removeLiquidity(uint256 amount) external {
        require(msg.sender == DAO, "Treasury: ACCESS_DENIED");
        require(amount > 0, "Treasury: INVALID_AMOUNT");
        require(IERC20(liquidityPair).transferFrom(msg.sender, address(this), amount), "Treasury: TRANSFER_FAILED");
        (uint256 amountA, uint256 amountB) = router.removeLiquidityETH(
            SDAO,
            amount,
            0,
            0,
            address(this),
            block.timestamp
        );
        balance -= amountA;
        require(IERC20(SDAO).transfer(DAO, amountA), "Treasury: TRANSFER_FAILED");
        require(address(this).balance >= amountB, "Treasury: INSUFFICIENT_ETH_BALANCE");
        payable(DAO).transfer(amountB);
    }
}
