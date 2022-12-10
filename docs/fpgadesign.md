# FPGA Design
We used the UPduino 3.1 FPGA board with an onboard Lattice iCE40 UltraPlus FPGA chip. Code was written in SystemVerilog.

The FPGA completes the following tasks:

  1. Read quadrature encoders
  2. Read setpoint from microcontroller over SPI
  3. Run a PID controller to provide a motor control signal
  4. Send a PWM signal to the motor driver

## Quadrature encoders
Quadrature decoding was accomplished using a simple state transition table inspired by [this](https://cdn.sparkfun.com/datasheets/Robotics/How%20to%20use%20a%20quadrature%20encoder.pdf) resource. The code in relevant part looks like this:

```SystemVerilog
    // s1,s2 are the quadrature inputs; p1,p2 are their previous values
    always_ff @(posedge clk) begin
		if (rst) begin
			position <= 0;
			p1 <= s1;
			p2 <= s2;
		end
		else begin
			case ({p2, p1, s2, s1})
				4'b0001: position <= position-1;
				4'b0010: position <= position+1;
				4'b0100: position <= position+1;
				4'b0111: position <= position-1;
				4'b1000: position <= position-1;
				4'b1011: position <= position+1;
				4'b1101: position <= position+1;
				4'b1110: position <= position-1;
				default: position <= position;
			endcase
		end

        p1 <= s1;
        p2 <= s2;
    end
```

## SPI setpoint
SPI read is similarly concise:
```SystemVerilog
module get_roll(
	input logic rst,
    input logic sck,
    input logic sdi,
    output logic sdo,
    input logic nss,
    output logic [15:0] roll);
	
	logic [15:0] bufr;

    always_ff @(posedge sck) begin
		if (rst) bufr <= 0;
        else bufr <= {bufr[14:0], sdi};  // Shift a new bit into the two-byte string
    end

	always_ff @(negedge nss) begin  // Publish new value when source select goes low
		if (rst) roll <= 0;
		roll <= bufr;
	end
endmodule
```

## PID controller
PID control was complicated by the FPGA's aversion to complex arithmetic (floating-point, division, etc.). We were, however, able to perform integer multiplications. Using 16-bit integers for most of the signals and a custom floating-point datatype composed of a 16-bit mantissa and an exponent for the PID constants, we implemented a fully-featured PID controller in SystemVerilog, factoring out division into the constants. 

Concretely, we transformed the familiar PID equation

`u(t) = k_pe(t)+k_I \int^t_0 e(x) dx + k_d \frac{d}{dt} e(t)`

where `u(t)` is the motor control signal at time `t`, `e(t)` is the error, and `k_p`, `k_i`, and `k_d` are the PID constants, to

`u(t) = k_p e_this+k_i(e_{accum}+=e_{this}) + k_d (e_{this}-e_{prev}`

where `e_{this}` is the current error, `e_{accum}` is the accumulated error, `+=` is as in C-like languages, and `e_{prev}` is the previous error value. For the integral, the following changes were made:

 * Cap the integral value to prevent abberations caused by the wheel being held away from the setpoint for a long time
 * Cap the integral increment value for a similar reason

For the derivative, these changes were made:

 * Only calculate the derivative every several thousand cycles (including using the "previous" value from several thousand cycles ago; for reference, the control loop runs at 6 mHz) to smooth out a choppy signal caused by low encoder resolution
 * Further derivative smoothing algorithms were prototyped but deemed unnecessary

In practice, many clamping modules were needed to prevent integer overflow. See the full source code for details.

## PWM
Pulse width modulation was accomplished using a configurable timer such that we could readily adjust the frequency as we experimented with various motor driver options. See the full source code for details.
