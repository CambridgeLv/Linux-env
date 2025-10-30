#Author: Lv Jianqiao (12120100) @Thu, 30 Jun 2022 02:23:03 -0700

if {[info object isa object radl_sheet]} {
    radl_sheet destroy
}


oo::class create radl_sheet {
    variable title
    variable content_list
    variable length_list
    variable content
    variable not_compiled

    constructor {} {
        set not_compiled 1
        set content_list {}
        set length_list {}
        set content ""
    }

    method title {str} {
        set title $str
    }

    method add {str} {
        lappend content_list $str
    }

    method compile {{sort n}} {
        foreach str $title {
            lappend length_list [string length $str]
        }
        foreach str_list $content_list {
            set tmp_list {}
            for {set i 0} {$i < [llength $str_list]} {incr i} {
                lappend tmp_list [tcl::mathfunc::max {*}[list "[string length [lindex $str_list $i]]" "[lindex $length_list $i]"]]
            }
            set length_list $tmp_list
        }
        set fmt ""
        set total_width 0
        foreach str_len $length_list {
            set word_length [expr ${str_len} + 1]
            set fmt "${fmt}%-${word_length}s"
            set total_width [expr $total_width + $word_length]
        }
        set content "\n"
        if {$sort == "n"} {
            set content "$content[format $fmt {*}$title]\n"
            set content "$content[string repeat = $total_width]\n"
            foreach line $content_list {
                set content "$content[format $fmt {*}$line]\n"
            }
        }


        set not_compiled 0
    }

    method print {} {
        if {$not_compiled} {
            my compile
        }
        return $content
    }
}
