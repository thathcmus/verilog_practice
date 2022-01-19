// Câu 1 : Thiết kếmạch đếm lên/xuống theo mã BCD (0-9) hiển thịra led 7 đoạn HEX0 với 
// tần sốkhoảng 1Hz được chia từclock 50MHz, chân Up/Down được gán cho SW0
module CAU1(input CLOCK_50Mhz, input SW, output [0:6] HEX0);
reg [3:0] count = 4'b0000;
reg [25:0] freq;
always @(posedge CLOCK_50Mhz) begin
    freq <= freq + 1'b1;
end
always @(posedge freq[25]) begin //Tại tần số 50Mhz/2^26 = 0.74Hz ~ 1Hz
    if(SW == 1 && count == 4'd9) count = 4'd0; //Giữ Ấn SW mà count = 9 thì count = 0
    else if(SW == 1 && count != 4'd9) count = count + 1'b1;//Giữ Ấn SW mà count khác 9 thì count cứ tăng
    else if(SW == 0 && count == 4'd0) count = 4'd9;//thả SW khi count = 0 thì tiếp theo count = 9
    else count = count - 1'b1;//Mặc định là đếm xuống ( trường hợp còn lain)
end
assign HEX0 =   (count==4'd0) ? 7'b0000001: //Đảo chiều và đảo bit với các mã của 7 đoạn ÂM CHUNG
                (count==4'd1) ? 7'b1001111:
                (count==4'd2) ? 7'b0010010:
                (count==4'd3) ? 7'b0000110:
                (count==4'd4) ? 7'b1001100:
                (count==4'd5) ? 7'b0100100:
                (count==4'd6) ? 7'b0100000:
                (count==4'd7) ? 7'b0001111:
                (count==4'd8) ? 7'b0000000:
                (count==4'd9) ? 7'b0000100: 7'b1111111;
endmodule

//=================================================================//

// Câu 2 : Thiết kếmạch cộng 2 số4 bit (sửdụng các switch làm ngõ vào) 
// hiển thị ra led 7 đoạn HEX1, HEX0 dưới dạng số thập phân
module CAU2(input [7:0] SW, output reg [0:6] HEX0, output reg [0:6] HEX1);
reg [4:0] donvi, chuc;
always @(*) begin
    donvi = (SW[7:4] + SW[3:0]) % 4'd10; //Cộng 2 SW sau đó lấy dư được đơn vị
    chuc = (SW[7:4] + SW[3:0]) / 4'd10; //Cộng hai SW sau đó lấy hàng chục
    case (donvi) //Tuỳ đơn vị mà HEX0 hiển thị ra, tương tự chục
        0: HEX0=7'b0000001;
        1: HEX0=7'b1001111;
        2: HEX0=7'b0010010;
        3: HEX0=7'b0000110;
        4: HEX0=7'b1001100;
        5: HEX0=7'b0100100;
        6: HEX0=7'b0100000;
        7: HEX0=7'b0001111;
        8: HEX0=7'b0000000;
        9: HEX0=7'b0000100;
        default: HEX0=7'b1111111;
    endcase
    case(chuc)
        0: HEX1=7'b0000001;
        1: HEX1=7'b1001111;
        2: HEX1=7'b0010010;
        3: HEX1=7'b0000110;
        default: HEX0=7'b1111111;
    endcase
end
endmodule

//=================================================================//

// Câu 3 : Thiết kế mạch dịch led sử dụng 8 led xanh, led sẽ chạy từ trái qua phải và
// dội lại từ phải qua trái với xung clock khoảng 1Hz được chia từ clock 50Mhz.

module CAU3(input CLOCK_50Mhz, output reg [7:0] LEDG);
reg flag;
reg [25:0] freq;
always @(posedge CLOCK_50Mhz)
    tanso <= tanso + 1'b1;

always @(posedge freq[25])
    if (LEDG[7:0] == 8'b00000000) //Nếu 8 LED tắt thì LED cao bật
        LEDG[7:0] = 8'b10000000;
    else
        if (flag==0) LEDG[7:0] <= {LEDG[0],LEDG[7:1]}; //LED Từ trái qua phải [Lấy bit nhỏ đưa về bit cao cho đến lúc b00000001]
        else LEDG[7:0] <= {LEDG[6:0],LEDG[7]}; // Flag = 1 thì LED từ phải qua trái [ Lấy bit cao đưa về bit thấp đến lúc b10000000]

    always @(posedge freq[25])
        if (LEDG[7:0]==8'b10000000) //Flag = 0 _ Xong 1 chu kì LED
            flag = 0;
        else if (LEDG[7:0]==8'b00000001) //Flag = 1
            flag = 1;
endmodule

//=================================================================//

// Câu 4 : Thiết kế mạch dịch led sử dụng 8 led đỏ
// với xung clock khoảng 1Hz được chia từ clock 50Mhz, mỗi lần bấm và thả ngay KEY thì led sẽ đứng yên,
// bấm và thả trong 3s led sẽ dịch trái, bấm và thả trong 5s led sẽ dịch phải
module CAU4(input CLOCK_50Mhz, input [0:0] KEY, output reg [7:0] LEDR);
reg [25:0] freq;
reg [3:0] flag;
reg [3:0] t;
always @(posedge CLOCK_50Mhz)
    freq <= freq + 1'b1;
always @(posedge freq[25])
    if (KEY[0:0] == 1)
        flag = 0;
    else
        flag <= flag + 1'b1;

always @(posedge KEY[0:0])
    t = flag;

always @(posedge freq[25])
begin
    if(LEDR == 0)
        LEDR <= LEDR + 1'b1;
    else
        if(t<=1)
            LEDR <= LEDR;
        else if(t >= 1 & t <= 4)
            LEDR = {LEDR[6:0],LEDR[7]};
        else if (t>=4)
            LEDR = {LEDR[0],LEDR[7:1]};
end
endmodule

//=================================================================//

// Câu 5: Thiết kế mạch dịch led sử dụng 8 led xanh với clock khoảng 1Hz được chia từ
// clock 50Mhz sao cho 2 led chạy từ ngoài vào giữa.
module CAU3(input CLOCK_50Mhz, output reg [7:0] LEDG);
reg flag;
reg [25:0] freq;
always @(posedge CLOCK_50Mhz)
    freq <= freq + 1'b1;

always @(posedge freq[25])
begin
    if (LEDG[7:0] == 8'b00000000) //Nếu 8 LED tắt thì LED cao bật
        LEDG[7:0] = 8'b1000_0001;
    else
        LEDG[7:0] <= {Q[4], Q[7:5], Q[2:0], Q[3]};
end
endmodule

//=================================================================//

// Câu 6: Thiết kếmạch hiển thịchữ“HELLO” lên 5 led 7 đoạn với 2 ngõ vào được gán với switch, 
// sao cho nếu switch = 2’b00 thì chữ“HELLO” nhấp nháy với tần sốkhoảng 1 Hz, 
// switch = 2’b01 thì khoảng 2 Hz, switch = 2’b10 thì khoảng 4 Hz 
// và switch = 2’b11 thì khoảng 8 Hz. 
// Clock được lấy từxung clock 50MHz.
module Verilog_Test(input CLOCK_50Mhz, input [1:0] SW, output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4);
reg [25:0] freq;
wire freq_point;
always @(posedge CLOCK_50Mhz)
    freq <= freq + 1'b1;
assign freq_point = (SW == 2'b00) ? freq[25]:
                    (SW == 2'b01) ? freq[24]:
                    (SW == 2'b10) ? freq[23]: freq[22];
assign HEX0 = (freq_point) ? 7'b0000001 : 7'b1111111;    //O
assign HEX1 = (freq_point) ? 7'b1110001 : 7'b1111111;    //L
assign HEX2 = (freq_point) ? 7'b1110001 : 7'b1111111;    //L
assign HEX3 = (freq_point) ? 7'b0110000 : 7'b1111111;    //E
assign HEX4 = (freq_point) ? 7'b1001000 : 7'b1111111;    //H
endmodule

//=================================================================//

// Câu 7: Thiết kếmạch đổi từsốnhịphân 9 bit (lấy từswitch) thành số
// thập phân hiển thịlên HEX2, HEX1 và HEX0

module CAU7(input [8:0] SW, output reg [0:6] HEX0, HEX1, HEX2);
reg [3:0] tram, chuc, donvi;
always @(*)
    begin 
        donvi = SW[8:0] % 4'd10;
        chuc = (SW[8:0] / 4'd10) % 4'd10;
        tram = (SW[8:0] / 4'd10) / 4'd10;
        case(donvi)
            0: HEX0 = 7'b0000001;
            1: HEX0 = 7'b1001111;
            2: HEX0 = 7'b0010010;
            3: HEX0 = 7'b0000110;
            4: HEX0 = 7'b1001100;
            5: HEX0 = 7'b0100100;
            6: HEX0 = 7'b0100000;
            7: HEX0 = 7'b0001111;
            8: HEX0 = 7'b0000000;
            9: HEX0 = 7'b0000100;
            default: HEX0 = 7'b1111111;
        endcase
        case(chuc)
            0: HEX1 = 7'b0000001;
            1: HEX1 = 7'b1001111;
            2: HEX1 = 7'b0010010;
            3: HEX1 = 7'b0000110;
            4: HEX1 = 7'b1001100;
            5: HEX1 = 7'b0100100;
            6: HEX1 = 7'b0100000;
            7: HEX1 = 7'b0001111;
            8: HEX1 = 7'b0000000;
            9: HEX1 = 7'b0000100;
            default: HEX1 = 7'b1111111;
        endcase
        case(tram)
            0: HEX2 = 7'b0000001;
            1: HEX2 = 7'b1001111;
            2: HEX2 = 7'b0010010;
            3: HEX2 = 7'b0000110;
            4: HEX2 = 7'b1001100;
            5: HEX2 = 7'b0100100;
            6: HEX2 = 7'b0100000;
            7: HEX2 = 7'b0001111;
            8: HEX2 = 7'b0000000;
            9: HEX2 = 7'b0000100;
            default: HEX2 = 7'b1111111;
        endcase
end
endmodule

//=================================================================//

// Câu 8 : Thiết kếmạch hiển thịchữ “HI” dịch từ trái qua phải ở
// 3 led 7 đoạn (từ HEX0 đến HEX3), xung clock khoảng 1Hz được chia từ clokc 50Mhz

module CAU8(input CLOCK_50Mhz, output reg [0:6] HEX0, HEX1, HEX2, HEX3);
reg [25:0] freq;
reg [1:0] q;
always @(posedge CLOCK_50Mhz)
    freq <= freq + 1'b1;
always @(posedge freq[25])
begin
    q <= q + 1'b1;
    if (q == 3)
        begin
            q <= 0;
        end
        case(q)
            0:begin
                HEX3 = 7'b1001000; //H
                HEX2 = 7'b1001111; //I
                HEX1 = 7'b1111111;
                HEX0 = 7'b1111111;
            end
            1:begin
                HEX3 = 7'b1111111;
                HEX2 = 7'b1001000; //H
                HEX1 = 7'b1001111; //I
                HEX0 = 7'b1111111;
            end
            2:begin
                HEX3 = 7'b1111111;
                HEX2 = 7'b1111111;
                HEX1 = 7'b1001000; //H
                HEX0 = 7'b1001111; //I
            end
            3:begin
                HEX3 = 7'b1001111; //I
                HEX2 = 7'b1111111;
                HEX1 = 7'b1111111;
                HEX0 = 7'b1001000; //H _ Xong quay lai 0_3_...
            end
        endcase
end
endmodule

//=================================================================//
// Câu 9 : Thiết kếmạch led 8 bit sáng dần từtrái qua phải vàtắt dần từphải qua trái.
module CAU9(input CLOCK_50Mhz, output reg [7:0] LEDG);
reg [25:0] freq;
reg flag;
always @(posedge CLOCK_50Mhz)
    freq <= freq + 1'b1;

always @(posedge freq[25])
    if(flag == 0)
        LEDG <= {1'b1, LEDG[7:1]}; // Đưa bit 1 lên cao _ sáng dần từ trái
    else LEDG <= {LEDG[6:0], 1'b0}; // Đưa bit 0 lên xuống thấp _ tắt dần từ phải

always @(posedge freq[25])
    if(LEDG == 8'b10000000) flag <= 0;
    else if (LEDG == 8'b11111110) flag <= 1;
endmodule

//=================================================================//
// Câu 10 : Thiết kếmạch bình phương 4 bit (sửdụngcác switch làm ngõ vào)
// hiển thịra led 7 đoạn HEX2, HEX1, HEX0 dưới dạng sốthập phân
module CAU10(input [3:0] SW, output reg [0:6] HEX0, HEX1, HEX2);
reg [3:0] tram, chuc, donvi;
always @(*)
    begin 
        donvi = (SW[3:0]*SW[3:0]) % 4'd10;
        chuc = ((SW[3:0]*SW[3:0]) / 4'd10) % 4'd10;
        tram = ((SW[3:0]*SW[3:0]) / 4'd10) / 4'd10;
        case(donvi)
            0: HEX0 = 7'b0000001;
            1: HEX0 = 7'b1001111;
            2: HEX0 = 7'b0010010;
            3: HEX0 = 7'b0000110;
            4: HEX0 = 7'b1001100;
            5: HEX0 = 7'b0100100;
            6: HEX0 = 7'b0100000;
            7: HEX0 = 7'b0001111;
            8: HEX0 = 7'b0000000;
            9: HEX0 = 7'b0000100;
            default: HEX0 = 7'b1111111;
        endcase
        case(chuc)
            0: HEX1 = 7'b0000001;
            1: HEX1 = 7'b1001111;
            2: HEX1 = 7'b0010010;
            3: HEX1 = 7'b0000110;
            4: HEX1 = 7'b1001100;
            5: HEX1 = 7'b0100100;
            6: HEX1 = 7'b0100000;
            7: HEX1 = 7'b0001111;
            8: HEX1 = 7'b0000000;
            9: HEX1 = 7'b0000100;
            default: HEX1 = 7'b1111111;
        endcase
        case(tram)
            0: HEX2 = 7'b0000001;
            1: HEX2 = 7'b1001111;
            2: HEX2 = 7'b0010010;
            3: HEX2 = 7'b0000110;
            4: HEX2 = 7'b1001100;
            5: HEX2 = 7'b0100100;
            6: HEX2 = 7'b0100000;
            7: HEX2 = 7'b0001111;
            8: HEX2 = 7'b0000000;
            9: HEX2 = 7'b0000100;
            default: HEX2 = 7'b1111111;
        endcase
	end
endmodule