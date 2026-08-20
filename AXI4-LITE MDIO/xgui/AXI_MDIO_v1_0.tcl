# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_CLK_FREQ_HZ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MDC_CLK_FREQ_HZ" -parent ${Page_0} -show_range false -widget comboBox
  set PHY_ADDR [ipgui::add_param $IPINST -name "PHY_ADDR" -parent ${Page_0}]
  set_property tooltip {PHY ADDR} ${PHY_ADDR}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_CLK_FREQ_HZ { PARAM_VALUE.AXI_CLK_FREQ_HZ } {
	# Procedure called to update AXI_CLK_FREQ_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_CLK_FREQ_HZ { PARAM_VALUE.AXI_CLK_FREQ_HZ } {
	# Procedure called to validate AXI_CLK_FREQ_HZ
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.MDC_CLK_FREQ_HZ { PARAM_VALUE.MDC_CLK_FREQ_HZ } {
	# Procedure called to update MDC_CLK_FREQ_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MDC_CLK_FREQ_HZ { PARAM_VALUE.MDC_CLK_FREQ_HZ } {
	# Procedure called to validate MDC_CLK_FREQ_HZ
	return true
}

proc update_PARAM_VALUE.PHY_ADDR { PARAM_VALUE.PHY_ADDR } {
	# Procedure called to update PHY_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PHY_ADDR { PARAM_VALUE.PHY_ADDR } {
	# Procedure called to validate PHY_ADDR
	return true
}


proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.PHY_ADDR { MODELPARAM_VALUE.PHY_ADDR PARAM_VALUE.PHY_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PHY_ADDR}] ${MODELPARAM_VALUE.PHY_ADDR}
}

proc update_MODELPARAM_VALUE.AXI_CLK_FREQ_HZ { MODELPARAM_VALUE.AXI_CLK_FREQ_HZ PARAM_VALUE.AXI_CLK_FREQ_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_CLK_FREQ_HZ}] ${MODELPARAM_VALUE.AXI_CLK_FREQ_HZ}
}

proc update_MODELPARAM_VALUE.MDC_CLK_FREQ_HZ { MODELPARAM_VALUE.MDC_CLK_FREQ_HZ PARAM_VALUE.MDC_CLK_FREQ_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MDC_CLK_FREQ_HZ}] ${MODELPARAM_VALUE.MDC_CLK_FREQ_HZ}
}

