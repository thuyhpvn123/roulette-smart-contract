Roulette:
Người chơi có thể chọn các loại sau tương ứng với betType từ 0->10:
 Split, Street, Corner, SixLine, Single, Trio, RedBlack, Column, Dozen, Eighteen, EvenOdd 
   0       1      2        3      4       5       6      7        8       9         10     
trong đó:
    RedBlack: 0 for black, 1 for red
    Column: 0 for left, 1 for middle, 2 for right
    Dozen: 0 for first, 1 for second, 2 for third
    Eighteen: 0 for low, 1 for high
    EvenOdd: 0 for even, 1 for odd
Số nhân tiền thắng tương ứng là : 17,11,8,5,35,11,2,3,3,2,2
mỗi lượt đặt đều tính phí house edge trả cho nhà cái( đang để măc định là 5%)
1. addEther: hàm nạp tiền vào contract
2. balanceOf: hàm kiểm tra số tiền thưởng chưa rút của người chơi , tiền có thể rút của owner
3. placeBet: người chơi đặt cược với input là loại đặt và các số đặt cho loại đó. Khi đặt cược thì chuyển số tiền muốn đặt nằm trong khoảng min, max quy định trong contract(đang để min=1000 wei, max = 10^18 wei)
4. spinRoulette: sau khi đặt cược thì sẽ gọi hàm quay số . hàm sẽ ra ngẫu nhiên 1 số từ 0->36 và so kết quả để ra được số tiền người chơi thắng nếu có.
5. cashout: người chơi /owner rút tiền
6. getContractBalance: kiểm tra số dư của contract
7. setMinimumBet: để owner đặt lại mức cược thấp nhất
8. setMaximumBet: để owner đặt lại mức cược cao nhất
9. setHouseEdge: để owner đặt lại tiền hoa hồng house egde.
