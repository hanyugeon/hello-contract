// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// saleAnimalToken을 생성해야 하지만 코드 구조상 불가능하다
// (시간상으로 MintAnimalToken.sol이 먼저 만들어지기 때문)
// 그래서 import로 가져온다.
import "SaleAnimalToken.sol";

contract MintAnimalToken is ERC721Enumerable {
    constructor() ERC721("h662Animals", "HAS") {}

    SaleAnimalToken public saleAnimalToken;

    mapping(uint256 => uint256) public animalTypes;

    struct AnimalTokenData {
        uint256 animalTokenId;
        uint256 animalType;
        uint256 animalPrice;
    }

    function mintAnimalToken() public {
        uint256 animalTokenId = totalSupply() + 1;
        uint256 animalType = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5) + 1;

        animalTypes[animalTokenId] = animalType;

        _mint(msg.sender, animalTokenId);
    }

    function getAnimalTokens(address _animalTokenOwner) view public returns(AnimalTokenData[] memory) {
        uint256 balanceLength = balanceOf(_animalTokenOwner);

        require(balanceLength != 0, "Owner did not have token.");

        AnimalTokenData[] memory animalTokenData = new AnimalTokenData[](balanceLength);

        // 스마트 컨트랙트 부분
        for (uint256 i = 0; i < balanceLength; i++) {
            uint256 animalTokenId = tokenOfOwnerByIndex(_animalTokenOwner, i);
            uint256 animalType = animalTypes[animalTokenId];
            uint256 animalPrice = saleAnimalToken.getAnimalTokenPrice(animalTokenId);

            animalTokenData[i] = AnimalTokenData(animalTokenId, animalType, animalPrice);
        }
      
      return animalTokenData;
    }

    function setSaleAnimalToken(address _saleAnimalToken) public {
        saleAnimalToken = SaleAnimalToken(_saleAnimalToken); 
    }
}
