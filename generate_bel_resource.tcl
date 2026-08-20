# ============================================================
# Generate FPGA BEL resource report
# Output:
# <PART>_BEL_resource.csv
# Saved in Vivado project directory
# ============================================================


# 获取 FPGA 型号
set part_name [get_property PART [current_project]]


# 获取工程目录
set proj_dir [get_property DIRECTORY [current_project]]


# 输出文件路径
set filename "${proj_dir}/${part_name}_BEL_resource.csv"


# Verify that BEL objects are available before truncating the output file.
set all_bels [get_bels -quiet]

if {[llength $all_bels] == 0} {
    error "No BEL objects found. Open a synthesized or implemented design before running this script."
}


# 打开 CSV 文件
set bel_fp [open $filename w]

set bel_write_status [catch {


# CSV 表头
puts $bel_fp "BEL_TYPE,COUNT"


# ============================================================
# 获取所有 BEL_TYPE
# ============================================================

set bel_types {}

foreach s $all_bels {

    set type [get_property TYPE $s]

    if {[lsearch -exact $bel_types $type] < 0} {
        lappend bel_types $type
    }
}


# ============================================================
# 统计每种 BEL_TYPE 数量
# ============================================================

foreach type [lsort $bel_types] {

    set num [llength [get_bels -quiet -filter "TYPE == $type"]]

    puts $bel_fp "$type,$num"

    puts [format "%-30s %8d" $type $num]
}


# 关闭文件
} bel_write_result bel_write_options]

set bel_close_status [catch {
    close $bel_fp
} bel_close_result bel_close_options]
unset bel_fp

if {$bel_write_status != 0} {
    return -options $bel_write_options $bel_write_result
}

if {$bel_close_status != 0} {
    return -options $bel_close_options $bel_close_result
}


puts ""
puts "=========================================="
puts "BEL resource report generated:"
puts $filename
puts "=========================================="
