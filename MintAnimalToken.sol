// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 오픈제플린 가져오기.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintAnimalToken is ERC721Enumerable {
    constructor() ERC721("h662Animals", "HAS") {}

    mapping(uint256 => uint256) public animalTypes;
    // 앞 uint = animalTokenId, 뒤 uint = animalTypes
    // TokenId 입력하면 animalTypes 나온다.

    function mintAnimalToken() public {
        // totalSupply() ERC721 토큰의 전체 발행량
        uint256 animalTokenId = totalSupply() + 1;

        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 + 1;
        // 함수 실행한 시간, 누가 실했는지, animalTokenId

        animalTypes[animalTokenId] = animalType;

        _mint(msg.sender, animalTokenId);
        // msg.sender = _mint를 실행 한 사람
        // animalTokenId = admin이 가지고 있는 TokenId
    }

}
