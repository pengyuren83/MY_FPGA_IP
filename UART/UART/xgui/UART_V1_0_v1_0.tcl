# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BAUD_RATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCK_FREQ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PARITY" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_FIFO_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RX_FIFO_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_FIFO_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_FIFO_DEPTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "UART_DATA_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.BAUD_RATE { PARAM_VALUE.BAUD_RATE } {
	# Procedure called to update BAUD_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAUD_RATE { PARAM_VALUE.BAUD_RATE } {
	# Procedure called to validate BAUD_RATE
	return true
}

proc update_PARAM_VALUE.CLOCK_FREQ { PARAM_VALUE.CLOCK_FREQ } {
	# Procedure called to update CLOCK_FREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_FREQ { PARAM_VALUE.CLOCK_FREQ } {
	# Procedure called to validate CLOCK_FREQ
	return true
}

proc update_PARAM_VALUE.PARITY { PARAM_VALUE.PARITY } {
	# Procedure called to update PARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PARITY { PARAM_VALUE.PARITY } {
	# Procedure called to validate PARITY
	return true
}

proc update_PARAM_VALUE.RX_FIFO_DATA_WIDTH { PARAM_VALUE.RX_FIFO_DATA_WIDTH } {
	# Procedure called to update RX_FIFO_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_FIFO_DATA_WIDTH { PARAM_VALUE.RX_FIFO_DATA_WIDTH } {
	# Procedure called to validate RX_FIFO_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RX_FIFO_DEPTH { PARAM_VALUE.RX_FIFO_DEPTH } {
	# Procedure called to update RX_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RX_FIFO_DEPTH { PARAM_VALUE.RX_FIFO_DEPTH } {
	# Procedure called to validate RX_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.TX_FIFO_DATA_WIDTH { PARAM_VALUE.TX_FIFO_DATA_WIDTH } {
	# Procedure called to update TX_FIFO_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_FIFO_DATA_WIDTH { PARAM_VALUE.TX_FIFO_DATA_WIDTH } {
	# Procedure called to validate TX_FIFO_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.TX_FIFO_DEPTH { PARAM_VALUE.TX_FIFO_DEPTH } {
	# Procedure called to update TX_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_FIFO_DEPTH { PARAM_VALUE.TX_FIFO_DEPTH } {
	# Procedure called to validate TX_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.UART_DATA_WIDTH { PARAM_VALUE.UART_DATA_WIDTH } {
	# Procedure called to update UART_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UART_DATA_WIDTH { PARAM_VALUE.UART_DATA_WIDTH } {
	# Procedure called to validate UART_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.BAUD_RATE { MODELPARAM_VALUE.BAUD_RATE PARAM_VALUE.BAUD_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BAUD_RATE}] ${MODELPARAM_VALUE.BAUD_RATE}
}

proc update_MODELPARAM_VALUE.CLOCK_FREQ { MODELPARAM_VALUE.CLOCK_FREQ PARAM_VALUE.CLOCK_FREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_FREQ}] ${MODELPARAM_VALUE.CLOCK_FREQ}
}

proc update_MODELPARAM_VALUE.UART_DATA_WIDTH { MODELPARAM_VALUE.UART_DATA_WIDTH PARAM_VALUE.UART_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UART_DATA_WIDTH}] ${MODELPARAM_VALUE.UART_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.PARITY { MODELPARAM_VALUE.PARITY PARAM_VALUE.PARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PARITY}] ${MODELPARAM_VALUE.PARITY}
}

proc update_MODELPARAM_VALUE.TX_FIFO_DATA_WIDTH { MODELPARAM_VALUE.TX_FIFO_DATA_WIDTH PARAM_VALUE.TX_FIFO_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_FIFO_DATA_WIDTH}] ${MODELPARAM_VALUE.TX_FIFO_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.TX_FIFO_DEPTH { MODELPARAM_VALUE.TX_FIFO_DEPTH PARAM_VALUE.TX_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_FIFO_DEPTH}] ${MODELPARAM_VALUE.TX_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.RX_FIFO_DATA_WIDTH { MODELPARAM_VALUE.RX_FIFO_DATA_WIDTH PARAM_VALUE.RX_FIFO_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_FIFO_DATA_WIDTH}] ${MODELPARAM_VALUE.RX_FIFO_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RX_FIFO_DEPTH { MODELPARAM_VALUE.RX_FIFO_DEPTH PARAM_VALUE.RX_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RX_FIFO_DEPTH}] ${MODELPARAM_VALUE.RX_FIFO_DEPTH}
}

