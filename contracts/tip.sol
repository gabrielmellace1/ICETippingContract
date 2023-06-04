// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EIP712MetaTransaction.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Tips is Ownable, EIP712MetaTransaction {
    uint256 public ownerCutPerMillion = 50000;
    IERC20 public ice = IERC20(0xc6C855AD634dCDAd23e64DA71Ba85b8C51E5aD7c);

    event ChangedOwnerCutPerMillion(uint256 ownerCutPerMillion);
    event TippedToken(address _to, address _from, uint256 _amount);

    constructor() EIP712Base("ICE tips", "v1.0") {}

    function setOwnerCutPerMillion(
        uint256 _ownerCutPerMillion
    ) external onlyOwner {
        require(
            _ownerCutPerMillion < 1000000,
            "The owner cut should be between 0 and 999,999"
        );

        ownerCutPerMillion = _ownerCutPerMillion;
        emit ChangedOwnerCutPerMillion(ownerCutPerMillion);
    }

    function tipToken(address _to, uint256 _amount) public {
        require(_amount > 0, "Amount should be > 0");

        uint256 saleShareAmount = 0;

        if (ownerCutPerMillion > 0) {
            // Calculate sale share
            saleShareAmount = (_amount * ownerCutPerMillion) / 1000000;

            // Transfer share amount for marketplace Owner
            require(
                ice.transferFrom(_msgSender(), owner(), saleShareAmount),
                "Transfer cut failed"
            );
        }

        // Transfer sale amount to seller
        require(
            ice.transferFrom(_msgSender(), _to, _amount - saleShareAmount),
            "Transfer tip failed"
        );

        emit TippedToken(_to, _msgSender(), _amount);
    }
}
