# Microcontroller Unit (MCU) Design

The controller we used is the STM32L432KC, which all students in E155 used. The MCU communicated with the inertial measurement unit (IMU) to obtain the roll angle. The IMU calculated this angle through a fusion of accelerometers, magnetometers, and gyroscopes, leading to a highly accurate reading. The MCU then used universal asynchronous receiver-transmitter (UART) protocol to communicate with the IMU. 

We then converted the angle to the number of encoder ticks the wheel had to rotate, and sent that value to the FPGA. This conversion was done through the following steps:

Convert the value of the raw data to rotations by dividing by 5760. This is done by converting to the angle in degrees (divide by 16) and then to rotations (divide by 360).
Convert rotations to encoder ticks by multiplying by 80.
Convert the angular displacement of the body to the wheel. This is done through the formula: x_b(1+m_b/m_w). x_b is the displacement of the body, m_b is the moment of inertia of the body, and m_w is the moment of inertia of the wheel.

After these values were converted, the data was sent to the FPGA through SPI (serial peripheral interface).
