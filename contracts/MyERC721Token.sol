// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyERC721Token is ERC721 {
    constructor() ERC721("MyERC721Token", "MTK") {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(from, tokenId),
            "MyERC721Token:::: caller is not token owner or approved"
        );

        _transfer(from, to, tokenId);
    }
}
