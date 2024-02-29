
# Jala Swap contest details

- Join [Sherlock Discord](https://discord.gg/MABEWyASkp)
- Submit findings using the issue page in your private contest repo (label issues as med or high)
- [Read for more details](https://docs.sherlock.xyz/audits/watsons)

# Q&A

### Q: On what chains are the smart contracts going to be deployed?
Chiliz Chain.
___

### Q: Which ERC20 tokens do you expect will interact with the smart contracts? 
JalaSwap anticipates engaging with Chiliz Chain's native token, CHZ, alongside other Fan Tokens within the same ecosystem, including FC Barcelona Fan Token (BAR) and Paris Saint-Germain Fan Token (PSG). 

It's important to note that while the protocol primarily interacts with ERC20 tokens, these specific tokens have a decimal setting of 0
___

### Q: Which ERC721 tokens do you expect will interact with the smart contracts? 
none.
___

### Q: Do you plan to support ERC1155?
No.
___

### Q: Which ERC777 tokens do you expect will interact with the smart contracts? 
None.
___

### Q: Are there any FEE-ON-TRANSFER tokens interacting with the smart contracts?

Yes only with router smart contract, not master router contract.

___

### Q: Are there any REBASING tokens interacting with the smart contracts?

No. 
___

### Q: Are the admins of the protocols your contracts integrate with (if any) TRUSTED or RESTRICTED?
TRUSTED 
___

### Q: Is the admin/owner of the protocol/contracts TRUSTED or RESTRICTED?
TRUSTED 
___

### Q: Are there any additional protocol roles? If yes, please explain in detail:
Roles: Fee Setter - responsible for adjusting fee rates within the JalaFactory Contract.

___

### Q: Is the code/contract expected to comply with any EIPs? Are there specific assumptions around adhering to those EIPs that Watsons should be aware of?
ERC-20
___

### Q: Please list any known issues/acceptable risks that should not result in a valid finding.
None.
___

### Q: Please provide links to previous audits (if any).
None.
___

### Q: Are there any off-chain mechanisms or off-chain procedures for the protocol (keeper bots, input validation expectations, etc)?
None. 
___

### Q: In case of external protocol integrations, are the risks of external contracts pausing or executing an emergency withdrawal acceptable? If not, Watsons will submit issues related to these situations that can harm your protocol's functionality.
Please submit any issue that could potentially compromise the JalaSwap protocol.


___

### Q: Do you expect to use any of the following tokens with non-standard behaviour with the smart contracts?
No. 
___

### Q: Add links to relevant protocol resources
Documentation: https://jalaswap.gitbook.io/jalaswap/ 
X: https://twitter.com/JalaSwap 
___



# Audit scope


[jalaswap-dex-contract @ 1629e1110572d961942b8f7167fe94a7f714a2e3](https://github.com/jalaswap/jalaswap-dex-contract/tree/1629e1110572d961942b8f7167fe94a7f714a2e3)
- [jalaswap-dex-contract/contracts/JalaFactory.sol](jalaswap-dex-contract/contracts/JalaFactory.sol)
- [jalaswap-dex-contract/contracts/JalaMasterRouter.sol](jalaswap-dex-contract/contracts/JalaMasterRouter.sol)
- [jalaswap-dex-contract/contracts/JalaPair.sol](jalaswap-dex-contract/contracts/JalaPair.sol)
- [jalaswap-dex-contract/contracts/JalaRouter02.sol](jalaswap-dex-contract/contracts/JalaRouter02.sol)
- [jalaswap-dex-contract/contracts/libraries/JalaLibrary.sol](jalaswap-dex-contract/contracts/libraries/JalaLibrary.sol)
- [jalaswap-dex-contract/contracts/utils/ChilizWrappedERC20.sol](jalaswap-dex-contract/contracts/utils/ChilizWrappedERC20.sol)
- [jalaswap-dex-contract/contracts/utils/ChilizWrapperFactory.sol](jalaswap-dex-contract/contracts/utils/ChilizWrapperFactory.sol)


