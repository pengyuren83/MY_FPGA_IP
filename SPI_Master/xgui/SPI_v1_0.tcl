# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set CMD_READ [ipgui::add_param $IPINST -name "CMD_READ" -parent ${Page_0} -widget comboBox]
  set_property tooltip {The value of command bit for read operation in a SPI frame} ${CMD_READ}
  set CMD_WRITE [ipgui::add_param $IPINST -name "CMD_WRITE" -parent ${Page_0} -widget comboBox]
  set_property tooltip {The value of command bit for write operation in a SPI frame} ${CMD_WRITE}
  set CPHA [ipgui::add_param $IPINST -name "CPHA" -parent ${Page_0} -widget comboBox]
  set_property tooltip {CPHA} ${CPHA}
  ipgui::add_param $IPINST -name "CPOL" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SCLK_DIV" -parent ${Page_0}


}

proc update_PARAM_VALUE.CMD_READ { PARAM_VALUE.CMD_READ } {
	# Procedure called to update CMD_READ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CMD_READ { PARAM_VALUE.CMD_READ } {
	# Procedure called to validate CMD_READ
	return true
}

proc update_PARAM_VALUE.CMD_WRITE { PARAM_VALUE.CMD_WRITE } {
	# Procedure called to update CMD_WRITE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CMD_WRITE { PARAM_VALUE.CMD_WRITE } {
	# Procedure called to validate CMD_WRITE
	return true
}

proc update_PARAM_VALUE.CPHA { PARAM_VALUE.CPHA } {
	# Procedure called to update CPHA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPHA { PARAM_VALUE.CPHA } {
	# Procedure called to validate CPHA
	return true
}

proc update_PARAM_VALUE.CPOL { PARAM_VALUE.CPOL } {
	# Procedure called to update CPOL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CPOL { PARAM_VALUE.CPOL } {
	# Procedure called to validate CPOL
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FRAME_WIDTH { PARAM_VALUE.FRAME_WIDTH } {
	# Procedure called to update FRAME_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_WIDTH { PARAM_VALUE.FRAME_WIDTH } {
	# Procedure called to validate FRAME_WIDTH
	return true
}

proc update_PARAM_VALUE.SCLK_DIV { PARAM_VALUE.SCLK_DIV } {
	# Procedure called to update SCLK_DIV when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SCLK_DIV { PARAM_VALUE.SCLK_DIV } {
	# Procedure called to validate SCLK_DIV
	return true
}


proc update_MODELPARAM_VALUE.SCLK_DIV { MODELPARAM_VALUE.SCLK_DIV PARAM_VALUE.SCLK_DIV } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SCLK_DIV}] ${MODELPARAM_VALUE.SCLK_DIV}
}

proc update_MODELPARAM_VALUE.FRAME_WIDTH { MODELPARAM_VALUE.FRAME_WIDTH PARAM_VALUE.FRAME_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_WIDTH}] ${MODELPARAM_VALUE.FRAME_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.CMD_WRITE { MODELPARAM_VALUE.CMD_WRITE PARAM_VALUE.CMD_WRITE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CMD_WRITE}] ${MODELPARAM_VALUE.CMD_WRITE}
}

proc update_MODELPARAM_VALUE.CMD_READ { MODELPARAM_VALUE.CMD_READ PARAM_VALUE.CMD_READ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CMD_READ}] ${MODELPARAM_VALUE.CMD_READ}
}

proc update_MODELPARAM_VALUE.CPOL { MODELPARAM_VALUE.CPOL PARAM_VALUE.CPOL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPOL}] ${MODELPARAM_VALUE.CPOL}
}

proc update_MODELPARAM_VALUE.CPHA { MODELPARAM_VALUE.CPHA PARAM_VALUE.CPHA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CPHA}] ${MODELPARAM_VALUE.CPHA}
}

