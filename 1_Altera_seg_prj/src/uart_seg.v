module uart_seg(
    input wire clk,          // 时钟信号
    input wire reset,        // 重置信号
    input wire rx,           // 接收引脚
    output reg [31:0] data_out,  // 转换后的二进制数据输出
    output reg data_valid   // 数据有效标志
);
    // 状态机状态定义
    localparam IDLE        = 2'b00;
    localparam RECEIVING   = 2'b01;
    localparam DONE        = 2'b10;
    localparam frame_head = 16'hFFFF;   // 帧头
//    localparam frame_tail = 16'h0000;   // 帧尾

    reg [1:0] state;             // 当前状态
    reg [31:0] data_sum;            // 累加接收到的二进制数据

    wire [7:0] rx_data;
    wire rx_data_ready;

    reg [15:0] temp_frame_head = 16'h0000;   // 用于存储接收到的帧头
	 reg [2:0] rx_cnt = 3'b000;               // 用于计数接收的有效值
//    reg [15:0] temp_frame_tail = 16'hFFFF;   // 用于存储接收到的帧尾

    // 实例化 UART 接收模块
    uart_rx uart_rx_inst (
        .sys_clk(clk),
        .sys_rst_n(reset),
        .rx(rx),
        .po_data(rx_data),
        .po_flag(rx_data_ready)
    );

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            data_sum <= 0;
            data_valid <= 0;
				data_out <= 0;
				rx_cnt <= 'd0;
            temp_frame_head <= 16'h0000;
//          temp_frame_tail <= 16'hFFFF;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    if (rx_data_ready) begin
                        // 检测帧头（完整的 16 位）
                        temp_frame_head <= {temp_frame_head[7:0], rx_data}; // 逐字节拼接
                    end						  
						  if (temp_frame_head == frame_head) begin
							 // 帧头匹配成功
							 state <= RECEIVING;
							 data_sum <= 0;
							end
                end
					 RECEIVING: begin
						 temp_frame_head <= 16'h0000;
						 data_valid <= 0;
						  if(rx_data_ready&&(rx_cnt!=4))
							 begin
							    rx_cnt <= rx_cnt + 1'b1;
							    data_sum <= (data_sum << 8) | rx_data;//传输数据
							 end
							else if(rx_cnt == 4)
							begin
								state <= DONE;
								data_sum <= data_sum;
							end	
							else 
								begin
									data_sum <= data_sum;
									state <= state;
								end
					 end
					 

//                RECEIVING: begin
//							temp_frame_head <= 16'h0000;
//                    if (rx_data_ready&&(temp_frame_tail != frame_tail)) begin
//                        // 检测帧尾（完整的 16 位）
//                        temp_frame_tail <= {temp_frame_tail[7:0], rx_data}; // 逐字节拼接
//								data_sum <= (data_sum << 8) | rx_data;//传输数据
//                        state <= state;
//                    end
//						  
//						 else if (temp_frame_tail == frame_tail) begin
//									 // 帧尾匹配成功，接收完成
//									 state <= DONE;
//				
//								end
//						 else begin
//							 data_sum <= data_sum;
//							 state <= state;
//							 end
//						end

						 DONE: begin
//								temp_frame_tail <= 16'hFFFF;
								rx_cnt <= 'd0;
							   data_out <= data_sum;  // 输出最终的累积结果
							   data_valid <= 1;
							   state <= IDLE;
						end
            endcase
        end
    end
endmodule