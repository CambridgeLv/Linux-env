#Author: Lv Jianqiao (12120100) @Sun, 03 Jul 2022 22:22:09 -0700

#1. PROC {{{
proc acp {in} {
    all_connected -leaf [get_nets -of [get_pins $in]]
}

proc acn {in} {
    all_connected -leaf [get_nets $in]
}

proc vcs2pt {in} {
    regsub -all {\.} $in {/} out
    puts $out
}

proc pt2vcs {in} {
    regsub -all {/} $in {.} out
    puts $out
}

proc gc {pin} {
    global synopsys_program_name
    if {$synopsys_program_name == "pt_shell"} {
        set name_attr "full_name"
    } elseif {$synopsys_program_name == "fc_shell"} {
        set name_attr "name"
    }
    set pin_col [get_pins $pin]
    foreach_in_col pin_name $pin_col {
        puts "[get_attr $pin_name $name_attr]: [get_attr $pin_name case_value]"
    }
}

proc gck {pin} {
    get_attr [get_pins $pin] clocks
}

proc lfr {coll} {
    foreach_in_coll name $coll {
        puts "[get_attr $name full_name], [get_attr $name ref_name]"
    }
}

proc lsc {coll} {
    foreach_in_coll name $coll {
        puts [get_attr $name full_name]
    }
}

proc lsa {coll attr} {
    foreach_in_coll name $coll {
        puts "[get_attr $name full_name], [get_attr $name $attr]"
    }
}

proc csp {tmp1 from tmp2 to} {
    change_selection [get_timing_path -from $from -to $to]
}

proc list_number_group {sep numbers} {
    # sep(separator group) number should from small to big
    # left <= value < right
    set tmp_list [list {*}$sep {*}$numbers]
    set sort_list [lsort -increasing -real $tmp_list]
    set sheet [radl_sheet new]
    $sheet title [list "Groups" "Vio num"]
    set result_group [list "-Inf" {*}$sep "+Inf"]

    set set_size [llength $sep]
    set except_last_size "0"
    for {set i 0} {$i < $set_size} {incr i} {
        set last_loc [expr [tcl::mathfunc::max {*}[lsearch $sort_list [lindex $sep $i]]] - $i]
        set cur_group_size [expr $last_loc - $except_last_size]
        set except_last_size "[expr $except_last_size + $cur_group_size]"
        $sheet add [list "[lindex $result_group $i] ~ [lindex $result_group [expr $i+1]]" "$cur_group_size"]
    }
    $sheet add [list "[lindex $result_group $set_size] ~ [lindex $result_group [expr $set_size+1]]" \
        "[expr [llength $numbers] - $except_last_size]"]

    return [$sheet print]
}

proc progres {cur tot} {
    # if you don't want to redraw all the time, uncomment and change ferquency
    #if {$cur % ($tot/300)} { return }
    # set to total width of progress bar
    set total 76
  
    set half [expr {$total/2}]
    set percent [expr {100.*$cur/$tot}]
    set val (\ [format "%6.2f%%" $percent]\ )
    set str "\r|[string repeat = [
                expr {round($percent*$total/100)}]][
                        string repeat { } [expr {$total-round($percent*$total/100)}]]|"
    set str "[string range $str 0 $half]$val[string range $str [expr {$half+[string length $val]-1}] end]"
    puts -nonewline stderr $str
}

proc logic_analysis {cur_timing_path} {
    #set cur_timing_path [get_timing_path -from $start -to $end]
    set points_ref_name [get_attribute [get_cells -of_objects [get_attr $cur_timing_path points.object]] ref_name]
    set inv_num [llength [lsearch -all -regexp $points_ref_name {\w\w\winv.*}]]
    set buf_num [llength [lsearch -all -regexp $points_ref_name {\w\w\wbuf.*}]]
    set true_num [expr [llength $points_ref_name]-$inv_num-$buf_num-2]
    return [list "$inv_num" "$buf_num" "$true_num"]
}

proc distance2point_direct {start end} {
    set start_bbox [get_attribute [get_pins $start] bbox]
    set end_bbox [get_attribute [get_pins $end] bbox]
    set start_center_point \
        "[expr ([lindex [lindex $start_bbox 0] 0]+[lindex [lindex $start_bbox 1] 0])/2] \
         [expr ([lindex [lindex $start_bbox 0] 1]+[lindex [lindex $start_bbox 1] 1])/2]"
    set end_center_point \
        "[expr ([lindex [lindex $end_bbox 0] 0]+[lindex [lindex $end_bbox 1] 0])/2] \
         [expr ([lindex [lindex $end_bbox 0] 1]+[lindex [lindex $end_bbox 1] 1])/2]"
    set distance [expr sqrt( \
        pow(([lindex $end_center_point 0] - [lindex $start_center_point 0]),2) + \
        pow(([lindex $end_center_point 1] - [lindex $start_center_point 1]),2) \
    )]
    return $distance
}

proc distance2point_xy {start end} {
    set start_bbox [get_attribute [get_pins $start] bbox]
    set end_bbox [get_attribute [get_pins $end] bbox]
    set start_center_point \
        "[expr ([lindex [lindex $start_bbox 0] 0]+[lindex [lindex $start_bbox 1] 0])/2] \
         [expr ([lindex [lindex $start_bbox 0] 1]+[lindex [lindex $start_bbox 1] 1])/2]"
    set end_center_point \
        "[expr ([lindex [lindex $end_bbox 0] 0]+[lindex [lindex $end_bbox 1] 0])/2] \
         [expr ([lindex [lindex $end_bbox 0] 1]+[lindex [lindex $end_bbox 1] 1])/2]"
    set distance [expr \
        abs([lindex $end_center_point 0] - [lindex $start_center_point 0]) + \
        abs([lindex $end_center_point 1] - [lindex $start_center_point 1])]
    return $distance
}

proc delay2point {start end} {
    set timing_path [get_timing_path -th $start -th $end]
    set arrival_list [get_attribute $timing_path points.arrival]
    set point_name_list [get_attribute $timing_path points.name]
    for {set i 0} {$i < [llength $point_name_list]} {incr i} {
        if {[lindex $point_name_list $i] eq $start} {
            set start_arrival [lindex $arrival_list $i]
        } elseif {[lindex $point_name_list $i] eq $end} {
            set end_arrival [lindex $arrival_list $i]
        }
    }
    return [expr $end_arrival - $start_arrival]
}

proc copy_macro_placement {coll} {
    foreach_in_collection cell $coll {
        set cell_fullname [get_attribute $cell full_name]
        set org [ get_attribute $cell origin ]
        set ori [ get_attribute $cell orientation ]

        puts "set_attribute  $cell_fullname -name origin -value \{ $org \}" 
        puts "set_attribute  $cell_fullname -name orientation -value $ori" 
    }
}

proc vim {args} {
    # Make a unique id by using pid and current history index
    regexp {^\s+(\d+)} [history -r 1] junk uniqid
    set tmpfile tmp4vim[pid]${uniqid}.ptlog
    redirect $tmpfile {uplevel $args}
    # Without redirect, exec echos the PID of the new process to the screen
    redirect /dev/null {catch {exec /bin/csh -c "gvim --nofork $tmpfile ; sleep 1; rm $tmpfile" &}}
}

proc &uniq { } {
    # Make a unique id by using pid and current history index
    regexp {^\s+(\d+)} [history -r 1] junk uniqid
    return [pid]${uniqid}
}

#fix cell full_name
proc fcf {ori_name} {
    regsub -all "_" $ori_name "?" try_name1
    regsub -all "/" $try_name1 "?" try_name
    set coll [get_cells -hier -filter "full_name =~ $try_name"]
    set res_name [get_object_name [get_pins $coll]]

    return $res_name
}

#fix pin full_name
proc fpf {ori_name} {
    regsub -all "_" $ori_name "?" try_name1
    regsub -all "/" $try_name1 "?" try_name
    set coll [get_pins -hier -filter "full_name =~ $try_name"]
    set res_name [get_object_name [get_pins $coll]]

    return $res_name
}

proc get_path_vio_noclk {start end} {
    set timing_path [get_timing_path -from $start -to $end]
    set slack [get_attribute $timing_path slack]
    set startpoint_clock_latency [get_attribute $timing_path startpoint_clock_latency]
    set endpoint_clock_latency [get_attribute $timing_path endpoint_clock_latency]
    set common_path_pessimism [get_attribute $timing_path common_path_pessimism ]
    set slack_without_clock [expr $slack + $startpoint_clock_latency - $endpoint_clock_latency - $common_path_pessimism]
    puts "$slack $startpoint_clock_latency $endpoint_clock_latency $common_path_pessimism $slack_without_clock"
}
# }}}
#2. ALIAS {{{
alias h history

alias rt   report_timing -input_pins -delay_type max -nets -to
alias rtm  report_timing -input_pins -delay_type min -nets -to
alias rf   report_timing -input_pins -delay_type max -nets -from
alias rfm  report_timing -input_pins -delay_type min -nets -from
alias rth  report_timing -input_pins -delay_type max -nets -through
alias rthm report_timing -input_pins -delay_type min -nets -through

alias afi all_fanin -flat -startpoints_only -to
alias afo all_fanout -flat -endpoints_only -from
# }}}
#3. SOURCE FILE {{{
source ~lvjianqi/Scripts/tcl/radl_sheet.tcl
source ~lvjianqi/Scripts/tcl/check_design_ext.tcl
source ~lvjianqi/Scripts/tcl/report_timing_by_module.tcl
source ~lvjianqi/Scripts/tcl/report_timing_by_module_start_end.tcl
source ~lvjianqi/Scripts/tcl/report_timing_by_module_start_end_v2.tcl
# }}}
