# ============================================================
# Generate FPGA SITE resource report
# Output:
# <PART>_SITE_resource.csv
# Saved in Vivado project directory
# ============================================================


# 获取 FPGA 型号
set part_name [get_property PART [current_project]]


# 获取工程目录
set proj_dir [get_property DIRECTORY [current_project]]


# 输出文件路径
set filename "${proj_dir}/${part_name}_SITE_resource.csv"


# 打开 CSV 文件
set site_fp [open $filename w]

set site_write_status [catch {


# CSV 表头
puts $site_fp "SITE_TYPE,COUNT"


# ============================================================
# 获取所有 SITE_TYPE
# ============================================================

set site_types {}

foreach s [get_sites] {

    set type [get_property SITE_TYPE $s]

    if {[lsearch -exact $site_types $type] < 0} {
        lappend site_types $type
    }
}


# ============================================================
# 统计每种 SITE_TYPE 数量
# ============================================================

foreach type [lsort $site_types] {

    set num [llength [get_sites -quiet -filter "SITE_TYPE == $type"]]

    puts $site_fp "$type,$num"

    puts [format "%-30s %8d" $type $num]
}


# 关闭文件
} site_write_result site_write_options]

set site_close_status [catch {
    close $site_fp
} site_close_result site_close_options]
unset site_fp

if {$site_write_status != 0} {
    return -options $site_write_options $site_write_result
}

if {$site_close_status != 0} {
    return -options $site_close_options $site_close_result
}


puts ""
puts "=========================================="
puts "SITE resource report generated:"
puts $filename
puts "=========================================="
