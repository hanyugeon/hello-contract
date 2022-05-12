# TIL

## 22.05.12

- 민팅 스마트 컨트랙트 작성
- 판매 스마트 컨트랙트 작성(+ 구매함수)
- remix IDE를 통해 민팅, 가격 책정, 구매 및 판매 실습 완료
- 정리
  - Mint.sol deploy (해당 주소 복사)
  - Sale.sol deplay (주소 붙여넣기)
  - Mint.sol에서 mint 진행 -> setApprovalForAll에서 (판매 주소, true) transact
  - Sale.sol에서 Id값 입력 및 가격(price)책정 (이후에 Id: 가격, 배열[idx]를 통해 조회 가능)
  - Account value에 책정된 가격을 입력하고 구매 진행 (이때 Account는 판매자와 다르게 진행할 것.)
