// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintAnimalToken.sol";

contract SaleAnimalToken {
    // MintAnimalToken을 진행하면 주소값이 나오는게 그 값을 담으려고 하는 과정임.
    MintAnimalToken public mintAnimalTokenAddress;

    constructor (address _mintAnimalTokenAddress) {
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    // 가격을 관리하는 매핑
    mapping(uint256 => uint256) public animalTokenPrices;
    // TokenId => price 이 되도록.

    // 앞단(FrontEnd)에서 판매중인 토큰을 확인 할 수 있게 해주는 배열생성
    uint256[] public onSaleAnimalTokenArray;

    // 판매 등록 함수
    function setForSaleAnimalToken(uint256 _animalTokenId, uint _price) public {
        // 주인이 판매 등록, 토큰Id를 넣으면 주인이 누구인지 출력(ownerOf())
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(animalTokenOwner == msg.sender, "Caller is not animal token owner.");
        require(_price > 0, "Price is zero or lower.");
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale.");
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token.");
        // animalTokenOwner: 주인, address(this): 이 SaleAnimalToken의 스마트 컨트랙트를 입력해줌.
        // 주인이 이 파일(스마트 컨트랙트)의 판매권한을 넘겼는지?
        /**
        * 처음부터 deploy 시작
        * MintAnimalToken.sol -> 주소 복사 -> SaleAnimalToken.sol(주소 붙여넣기)
        * 민팅 1회 시행 -> TokenId: 1 _price: 10 실행
        * 에러 발생: 4번째 require문에서 에러 발생했음.
        * Mint에서 isApprovedForAll(account주소, Sale.sol 주소) => 실행 => 에러
        * Mint에서 setApprovalForAll(Sale.sol 주소, true) => 실행
        * 이후 다시 Sale.sol가서 setForSaleAnimalToken 실행 해보기 (성공)
        * animalTokenPrices에 1 넣어서 _price 확인해보기 => 10
        * onSaleAnimalTokenArray에 idx값 0 넣어서 return 값이 1인지 확인해보기 => 1
        */

        animalTokenPrices[_animalTokenId] = _price;

        onSaleAnimalTokenArray.push(_animalTokenId);
    }

    function purchaseAnimalToken(uint256 _animalTokenId) public payable {
        uint256 price = animalTokenPrices[_animalTokenId];
        // 토큰 주인의 주소 정의
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(price > 0, "Animal token not sale");
        require(price <= msg.value, "Caller sent lower than price.");
        // msg.value 이 함수를 실행할 때 보내는 매직의 양? 전달 된 이더 값?
        // 여기서 매직은 뭘 말하는 건지: 구매자가 사려고 전달하는 값인것 같음.
        require(animalTokenOwner != msg.sender, "Caller is animal token owner");
        // 토큰 주인이 이 요청을 할 수 없게 막는 require문

        // animalTokenOwner에게 msg.value를 전달
        // 토큰을 구매하기 위해 Ownerd에게 값을 지불했다.
        payable(animalTokenOwner).transfer(msg.value);
        // (보내는 사람, 받는사람, 보낼 값: TokenId)
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId);

        // 토큰의 값을 0으로 만듦 why? 32번 require문 참조.
        animalTokenPrices[_animalTokenId] = 0;

        // 이 for문 이해 못하면 그냥 개발공부 접자? ^^ (이해했다는 뜻.)
        for (uint256 i = 0; i < onSaleAnimalTokenArray.length; i++) {
            if(animalTokenPrices[onSaleAnimalTokenArray[i]] == 0) {
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                onSaleAnimalTokenArray.pop();
            }
        }
    }

    // 앞단(FrontEnd)에서 활용 할 함수
    // 20Line for문 돌려서 항목을 조회할 수 있도록 하는 함수.
    function getOnSaleAnimalArrayLength() view public returns (uint256) {
        return onSaleAnimalTokenArray.length;
    }
}
