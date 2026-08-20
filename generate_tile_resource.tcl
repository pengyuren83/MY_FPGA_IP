# ============================================================
# Generate FPGA TILE resource report
# Output:
# <PART>_TILE_resource.csv
# Saved in Vivado project directory
# ============================================================


# 获取 FPGA 型号
set part_name [get_property PART [current_project]]


# 获取工程目录
set proj_dir [get_property DIRECTORY [current_project]]


# 输出文件路径
set filename "${proj_dir}/${part_name}_TILE_resource.csv"


# 打开 CSV 文件
set tile_fp [open $filename w]

set tile_write_status [catch {


# CSV 表头
puts $tile_fp "TILE_TYPE,COUNT"


# ============================================================
# 获取所有 TILE_TYPE
# ============================================================

set tile_types {}

foreach s [get_tiles] {

    set type [get_property TILE_TYPE $s]

    if {[lsearch -exact $tile_types $type] < 0} {
        lappend tile_types $type
    }
}


# ============================================================
# 统计每种 SITE_TYPE 数量
# ============================================================

foreach type [lsort $tile_types] {

    set num [llength [get_tiles -quiet -filter "TILE_TYPE == $type"]]

    puts $tile_fp "$type,$num"

    puts [format "%-30s %8d" $type $num]
}


# 关闭文件
} tile_write_result tile_write_options]

set tile_close_status [catch {
    close $tile_fp
} tile_close_result tile_close_options]
unset tile_fp

if {$tile_write_status != 0} {
    return -options $tile_write_options $tile_write_result
}

if {$tile_close_status != 0} {
    return -options $tile_close_options $tile_close_result
}


puts ""
puts "=========================================="
puts "TILE resource report generated:"
puts $filename
puts "=========================================="
