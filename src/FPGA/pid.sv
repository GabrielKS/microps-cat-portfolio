module pid_16(  // PID control with 16-bit signed integers
	input logic clk, rst,
	input logic signed [15:0] kp_n, kp_ds,
	input logic signed [15:0] ki_n, ki_ds,
	input logic signed [15:0] kd_n, kd_ds,
	input logic signed [31:0] max_integral,
	input logic signed [15:0] max_integral_step,
	input logic signed [31:0] derivative_downsample,
	input logic signed [15:0] setpoint, observed,
	output logic signed [15:0] out);

	logic signed [15:0] error, derivative_this, derivative_avg, derivative_buf, derivative_filtered, error_clamped, old_error;
	logic signed [31:0] integral, integral_unclamped, integral_clamped, derivative_counter;
	assign error = setpoint-observed;
	clamp_16 eclamp(error, -max_integral_step, max_integral_step, error_clamped);
	assign integral_unclamped = integral+error_clamped;
	clamp_32 iclamp(integral_unclamped, -max_integral, max_integral, integral_clamped);
	assign derivative_avg = (derivative_buf < 0) ? -((-derivative_buf) >>> 4) : (derivative_buf >>> 4);
	//assign derivative_avg = derivative_buf >>> 4;
	//assign derivative_avg = -((-derivative_buf) >>> 4);
	assign derivative_filtered = ((derivative_this > 1) || (derivative_this < -1)) ? derivative_this : 0;

	always_ff @(posedge clk) begin
		if (rst) begin
			integral <= 0;
			derivative_counter <= 0;
			old_error <= error;
			derivative_buf <= 0;
		end
		else begin
			// Integral takes new state
			integral <= integral_clamped;
			
			// Is it time to update the derivative?
			if (derivative_counter == derivative_downsample) begin
				derivative_this = error-old_error;  // Derivative takes new state
				derivative_buf <= ((derivative_avg <<< 4) - (derivative_avg <<< 1) + ((error-old_error) <<< 5));
				old_error <= error;
				derivative_counter <= 0;
			end
			else derivative_counter <= derivative_counter+1;
		end
	end
	
	logic signed [15:0] p_term, i_term, d_term;
	multiply_clamp mp(error, kp_n, kp_ds, p_term);
	multiply_clamp_big mi(integral, ki_n, ki_ds, i_term);
	multiply_clamp md(derivative_this, kd_n, kd_ds, d_term);
	logic signed [31:0] big_sum;
	assign big_sum = p_term+i_term+d_term;
	clamp_32_16 c(big_sum, out);
endmodule

module multiply_clamp(
	input logic signed [15:0] m1, numer, denom_pow,
	output logic signed [15:0] out);

	logic signed [31:0] step1, step2;
	assign step1 = {{16{m1[15]}}, m1}*{{16{numer[15]}}, numer};  // Manually sign-extend to promote bitlength
	assign step2 = (denom_pow >= 0) ? (step1 >>> denom_pow) : (step1 <<< (-denom_pow));
	clamp_32_16 c(step2, out);
endmodule

// Version of multiply_clamp designed for 32-bit inputs. Does the right-shifting before the multiplication to avoid overflow.
module multiply_clamp_big(
	input logic signed [31:0] m1,
	input logic signed [15:0] numer, denom_pow,
	output logic signed [15:0] out);

	logic signed [31:0] step1, step2;
	assign step1 = (denom_pow >= 0) ? (m1 >>> denom_pow) : (m1 <<< (-denom_pow));
	assign step2 = step1*{{16{numer[15]}}, numer};
	clamp_32_16 c(step2, out);
endmodule

module clamp_32(
	input logic signed [31:0] n, min, max,
	output logic signed [31:0] out);
	assign out = (n < min) ? min : ((n > max) ? max : n);
endmodule

module clamp_32_16(
	input logic signed [31:0] n,
	output logic signed [15:0] out);
	assign out = (n < -'sd32768) ? -'sd32768 : ((n > 'sd32767) ? 'sd32767 : n);
endmodule

module clamp_16(
	input logic signed [15:0] n, min, max,
	output logic signed [15:0] out);
	assign out = (n < min) ? min : ((n > max) ? max : n);
endmodule

module rssym_16(  // Right shift symmetric: right shift but round towards zero instead of negative infinity
	input logic signed [15:0] n,
	input logic [4:0] shift_amt,  // 'shiftand'?
	output logic signed [15:0] out);
	assign out = (n < 0) ? -((-n) >>> shift_amt) : (n >>> shift_amt);
endmodule