// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 오픈제플린 가져오기.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// saleAnimalToken을 생성해야 하지만 코드 구조상 불가능하다
// (시간상으로 MintAnimalToken.sol이 먼저 만들어지기 때문)
// 그래서 import로 가져온다.
import "SaleAnimalToken.sol";

contract MintAnimalToken is ERC721Enumerable {
    constructor() ERC721("h662Animals", "HAS") {}

    SaleAnimalToken public saleAnimalToken;

    mapping(uint256 => uint256) public animalTypes;

    // 구조체를 활용하여 for문 한꺼번에 넘겨주는 걸로한다.
    struct AnimalTokenData {
        uint256 animalTokenId;
        uint256 animalType;
        uint256 animalPrice;
    }

    // 앞 uint = animalTokenId, 뒤 uint = animalTypes
    // TokenId 입력하면 animalTypes 나온다.

    function mintAnimalToken() public {
        // totalSupply() ERC721 토큰의 전체 발행량
        uint256 animalTokenId = totalSupply() + 1;

        uint256 animalType = (uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, animalTokenId)
            )
        ) % 5) + 1;
        // 함수 실행한 시간, 누가 실했는지, animalTokenId

        animalTypes[animalTokenId] = animalType;

        _mint(msg.sender, animalTokenId);
        // msg.sender = _mint를 실행 한 사람
        // animalTokenId = admin이 가지고 있는 TokenId
    }

    // view는 읽기 전용
    // storage에 저장되지 않게 memory를 사용하자.
    // storage: 영구 저장 memory: 함수가 실행 될 때만 저장(string 타입이나 array 타입은 표시를 해주는게 좋다.)
    function getAnimalTokens(address _animalTokenOwner) view public returns(AnimalTokenData[] memory) {
        uint256 balanceLength = balanceOf(_animalTokenOwner);

        require(balanceLength != 0, "Owner did not have token.");

        // AnimalTokenData[](배열의 길이)
        AnimalTokenData[] memory animalTokenData = new AnimalTokenData[](balanceLength);

        // 스마트 컨트랙트 부분
        for(uint256 i = 0; i < balanceLength; i++) {
            uint256 animalTokenId = tokenOfOwnerByIndex(_animalTokenOwner, i);
            // mapping이기 때문에 []로 조회
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
