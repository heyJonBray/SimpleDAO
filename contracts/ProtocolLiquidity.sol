pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./UniswapV2Library.sol";
import "./UniswapV2Pair.sol";
import "./UniswapV2Router.sol";

contract ProtocolLiquidity {
    address public immutable SDAO;
    address public immutable WETH;
    address public immutable treasury;

    UniswapV2Router public immutable router;
    UniswapV2Pair public immutable pair;
    uint256 public totalLiquidity;

    constructor(address _SDAO, address _WETH, address _treasury, UniswapV2Router _router) {
        SDAO = _SDAO;
        WETH = _WETH;
        treasury = _treasury;
        router = _router;

        pair = UniswapV2Pair(UniswapV2Library.pairFor(address(router.factory()), SDAO, WETH));
        IERC20(SDAO).approve(address(router), type(uint256).max);
        IERC20(WETH).approve(address(router), type(uint256).max);
    }

    function addLiquidity(uint256 sdaoAmount, uint256 ethAmount) external {
        require(IERC20(SDAO).transferFrom(msg.sender, address(this), sdaoAmount), "SDAO transfer failed");
        require(IERC20(WETH).transferFrom(msg.sender, address(this), ethAmount), "ETH transfer failed");

        (uint256 sdaoRes, uint256 ethRes,) = pair.getReserves();
        uint256 liquidity;
        if (totalLiquidity == 0) {
            liquidity = UniswapV2Library.quote(sdaoAmount, ethRes, sdaoRes);
            require(IERC20(SDAO).transfer(treasury, sdaoAmount), "SDAO transfer to treasury failed");
            require(IERC20(WETH).transfer(treasury, ethAmount), "ETH transfer to treasury failed");
        } else {
            uint256 ethAmountEquivalent = UniswapV2Library.quote(sdaoAmount, sdaoRes, ethRes);
            liquidity = UniswapV2Library.quote(sdaoAmount, totalLiquidity, sdaoRes);
            require(IERC20(SDAO).transfer(treasury, sdaoAmount), "SDAO transfer to treasury failed");
            require(IERC20(WETH).transfer(treasury, ethAmountEquivalent), "ETH transfer to treasury failed");
        }
        pair.mint(address(this));
        require(IERC20(pair).transfer(treasury, liquidity), "Liquidity transfer to treasury failed");
        totalLiquidity += liquidity;
    }

    function removeLiquidity(uint256 liquidity) external {
        require(IERC20(pair).transferFrom(msg.sender, address(this), liquidity), "Liquidity transfer failed");
        uint256 amount0;
        uint256 amount1;
        (amount0, amount1) = pair.burn(address(this));
        require(IERC20(SDAO).transfer(treasury, amount0), "SDAO transfer to treasury failed");
        require(IERC20(WETH).transfer(treasury, amount1), "ETH transfer to treasury failed");
        totalLiquidity -= liquidity;
    }
}
