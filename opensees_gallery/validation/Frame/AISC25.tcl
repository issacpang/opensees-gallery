# 2D Columns with P-Delta Effects 
#
# REFERENCES:
# R.C.Kaehler, D.W.White, Y.D.Kim, "Frame Design Using Web-Tapered Members", AISC 2011
#
puts "AISC - Design Guide 25 - Frame Design Using Web-Tapered Members"
puts "Prismatic Beam Benchmark Problems\n"

set indent "  "

proc Case1 {element subdivide alpha {integration ""}} {
    global indent
    wipe
    model Basic -ndm 2

    set H  10.0
    set L 196.0
    set PI [expr 2.0*asin(1.0)]


    set E 29500.0
    set A 51.7
    set I 2150.0
    set node_count [expr $subdivide+1]

    set Pel [expr $PI*$PI*$E*$I/($L*$L)]
    set Pcr [expr $Pel/4.0]
    set Pr  $Pcr

    set dY [expr $L/$subdivide]
    for {set i 0} {$i <= $subdivide} {incr i 1} {
        node [expr $i +1] 0. [expr $i * $dY]
    }

    geomTransf PDelta 1
    section Elastic 1 $E $A $I
    set tag 1; set iNode 1; set jNode 2;
    for {set i 0} {$i < $subdivide} {incr i} {
      if {$integration != ""} {
        element $element $tag $iNode $jNode 1 $integration
      } else {
        element $element $tag $iNode $jNode -section 1 -transform 1
      }
      incr tag; incr iNode; incr jNode;
    }

    fix 1 1 1 1

    set u    [expr $PI/2.0*sqrt($alpha * $Pr/$Pel)]

    if {$u != 0} {
        set resU [expr ($H*$L*$L*$L/(3.0*$E*$I)) * (3.0*(tan(2.0*$u)-2.0*$u)/(8.0*$u*$u*$u))]
        set resM [expr $H*$L*(tan(2.*$u)/(2.*$u))]
    } else {
        set resU [expr ($H*$L*$L*$L/(3.0*$E*$I))]
        set resM [expr $H*$L]
    }

    pattern Plain 1 Linear {
        load  $node_count $H [expr -$alpha*$Pr] 0.
    }

    constraints Plain
    system ProfileSPD
    numberer Plain
    integrator LoadControl 1
    test NormDispIncr 1.0e-12 6 0
    algorithm Newton
    analysis Static
    set ok [analyze 1]

    set delta [nodeDisp [expr $subdivide + 1] 1]
    set moment [lindex [eleResponse 1 forces] 2]
    set formatString "$indent%6.0f|%8.2f|%8.4f|%9.4f|%6.1f|%9.2f|%8.2f|%6.1f"
    puts [format $formatString $subdivide $alpha $resU $delta [expr 100*($resU-$delta)/$delta] $resM $moment [expr 100*($resM-$moment)/$moment] ]


    if {[expr abs(100*($resU-$delta)/$delta)] > 0.5 || [expr abs(100*($resM-$moment)/$moment)] > 0.5} {
        set ok 1
#       puts "[expr abs(100*($resU-$delta)/$delta)] > 0.5 || [expr abs(100*($resM-$moment)/$moment)] > 0.5"
    }

    return $ok
}

proc Case2 {element subdivide alpha {integration ""}} {
    global indent
    wipe
    model Basic -ndm 2
    
    set H  10.0
    set L 196.0
    set PI [expr 2.0*asin(1.0)]

    set E 29500.0
    set A 51.7
    set I 2150.0
    
    set Pel [expr $PI*$PI*$E*$I/($L*$L)]
    set Pcr [expr $Pel/4.0]
    set Pr  $Pcr
    
    set dY [expr $L/$elem_count]
    for {set i 0} {$i <= $elem_count} {incr i 1} {
        node [expr $i +1] 0. [expr $i * $dY]
    }
    
    geomTransf PDelta 1
    set tag 1; set iNode 1; set jNode 2;
    for {set i 0} {$i < $elem_count} {incr i} {
      if {$integration != ""} {
        element $element $tag $iNode $jNode 1 $integration
      } else {
        element $element $tag $iNode $jNode -section 1 -transform 1
      }
      incr tag; incr iNode; incr jNode;
    }
    
    fix 1 1 1 1
    fix [expr $elem_count+1] 0 0 1
    
    set u    [expr $PI/2.0*sqrt($alpha * $Pr/$Pel)]
    
    if {$u != 0} {
        set resU [expr ($H*$L*$L*$L/(12.0*$E*$I)) * (3.0*(tan($u)-$u)/($u*$u*$u))]
        set resM [expr $H*$L/2.0*(tan($u)/($u))]
    } else {
        set resU [expr ($H*$L*$L*$L/(12.0*$E*$I))]
        set resM [expr $H*$L/2.0]
    }
    
    pattern Plain 1 Linear {
        load  [expr $elem_count+1] $H [expr -$alpha*$Pr] 0.
    }
    
    constraints Plain
    system ProfileSPD
    numberer Plain
    integrator LoadControl 1
    test NormDispIncr 1.0e-12 6 0
    algorithm Newton
    analysis Static
    analyze 1
    
    set delta [nodeDisp [expr $elem_count + 1] 1]
    set moment [lindex [eleResponse 1 forces] 2]
    set formatString "$indent%6.0f|%8.2f|%8.4f|%9.4f|%6.1f|%9.2f|%8.2f|%6.1f"
    puts [format $formatString $elem_count $alpha $resU $delta [expr 100*($resU-$delta)/$delta] $resM $moment [expr 100*($resM-$moment)/$moment] ]

  # if {[expr abs(100*($resU-$delta)/$delta)] > 0.5 || [expr abs(100*($resM-$moment)/$moment)] > 0.5} {
  #     set ok 1
  #     puts "[expr abs(100*($resU-$delta)/$delta)] > 0.5 || [expr abs(100*($resM-$moment)/$moment)] > 0.5"
  # }
}

set H  10.0
set L 196.0
set PI [expr 2.0*asin(1.0)]

set ok 0
set results {}
puts ":: Case 1 (Single Curvature)     - ElasticBeamColumn"
puts "$indent------+--------+-------------------------+-------------------------"
puts "$indent      |        |     Tip Displacement    |      Base Moment        "
puts "$indent------+--------+--------+---------+------+---------+--------+------"
set formatString "$indent%5s|%8s|%8s|%9s|%6s|%9s|%8s|%6s"
puts [format $formatString mesh alpha Exact OpenSees %Error Exact OpenSees %Error]
puts "$indent------+--------+--------+---------+------+---------+--------+------"

foreach elem_count {1 2 4 10} {
    foreach alpha {0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.67} {
        set ok [Case1 elasticBeamColumn $elem_count $alpha]
    }
    puts "$indent------+--------+--------+---------+------+---------+--------+------"
}

# test on last one

puts "\n\n:: Case 1 (Single Curvature) - ForceBeamColumnCBDI element"
puts "$indent------+--------+-------------------------+-------------------------"
puts "$indent      |        |     Tip Displacement    |      Base Moment        "
puts "$indent------+--------+--------+---------+------+---------+--------+------"
set formatString "$indent%5s|%8s|%8s|%9s|%6s|%9s|%8s|%6s"
puts [format $formatString mesh alpha Exact OpenSees %Error Exact OpenSees %Error]
puts "$indent------+--------+--------+---------+------+---------+--------+------"
foreach elem_count {1 } {
    foreach alpha {0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.67} {
        set ok [Case1 forceBeamColumnCBDI $elem_count $alpha "Legendre 1 4"]
    }
    puts "$indent------+--------+--------+---------+------+---------+--------+------"
}

puts "\n\n:: Case 2 (Double Curvature)  - ElasticBeamColumn"
puts "$indent------+--------+-------------------------+-------------------------"
puts "$indent      |        |     Tip Displacement    |      Base Moment        "
puts "$indent------+--------+--------+---------+------+---------+--------+------"
set formatString "$indent%5s|%8s|%8s|%9s|%6s|%9s|%8s|%6s"
puts [format $formatString mesh alpha Exact OpenSees %Error Exact OpenSees %Error]
puts "$indent------+--------+--------+---------+------+---------+--------+------"
foreach elem_count {1 2 10} {
    foreach alpha {0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.67} {
        set ok [Case1 elasticBeamColumn $elem_count $alpha]
    }
    puts "$indent------+--------+--------+---------+------+---------+--------+------"
}


set results [open STATUS.md a+]
if {$ok == 0} {
    puts "PASSED Verification Test AISC25.tcl \n\n"
    puts $results "| PASSED |  AISC25.tcl |"
} else {
    puts "FAILED Verification Test AISC25.tcl \n\n"
    puts $results "| FAILED |  AISC25.tcl |"
}

close $results