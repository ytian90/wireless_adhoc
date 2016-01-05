# ========================================================================================
#                      Wireless Ad-hoc Routing Protocol AODV
#                      Author: YU TIAN
#=========================================================================================

# Protocol options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             10                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              1000                       ;# X dimension of topography
set val(y)              1000                       ;# Y dimension of topography
set val(stop)           1000                         ;# time of simulation end

#Creat Simulator object
set ns [new Simulator]

#set up trace files
set tracefd       [open aodv_udp2.tr w]
set namtrace      [open aodv_udp2.nam w]
set windowVsTime2 [open win2.tr w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

#Set up Topgraphy
set topo       [new Topography]

#Topgraphy border
$topo load_flatgrid $val(x) $val(y)

#General Operations Director.store global information
#state of the environment, network or nodes
create-god $val(nn)

#Congifure wireless nodes
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channelType $val(chan) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace ON

#Create the nodes
for {set i 0} {$i < $val(nn) } { incr i } {
    set node_($i) [$ns node]
}

# Provide initial location of mobilenodes
$node_(0) set X_ 1.0
$node_(0) set Y_ 500.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 1.0
$node_(1) set Y_ 500.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 1.0
$node_(2) set Y_ 500.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 1.0
$node_(3) set Y_ 500.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 1.0
$node_(4) set Y_ 500.0
$node_(4) set Z_ 0.0

$node_(5) set X_ 999.0
$node_(5) set Y_ 500.0
$node_(5) set Z_ 0.0

$node_(6) set X_ 999.0
$node_(6) set Y_ 500.0
$node_(6) set Z_ 0.0

$node_(7) set X_ 999.0
$node_(7) set Y_ 500.0
$node_(7) set Z_ 0.0

$node_(8) set X_ 999.0
$node_(8) set Y_ 500.0
$node_(8) set Z_ 0.0

$node_(9) set X_ 999.0
$node_(9) set Y_ 500.0
$node_(9) set Z_ 0.0


# Generation of movements
# $ns at 3.9 "$node_(6) setdest 50.0 40.0 250.0"

#Movement for nodes starting from left edge (0-4)
for {set t 0} {$t < 500} { incr t} {
  for {set i 0} {$i < 5 } { incr i } {
    set rnum [expr {rand()}]
    if {$rnum < 0.25} {
      $ns at expr{$t} "$node_($i) setdest 999.5 999.5 1.0"
    } elseif {$rnum < 0.5} {
      $ns at expr{$t} "$node_($i) setdest 999.5 750.0 1.0"
    } elseif {$rnum < 0.75} {
      $ns at expr{$t} "$node_($i) setdest 999.5 250.0 1.0"
    } else {
      $ns at expr{$t} "$node_($i) setdest 999.5 0.5 1.0"
    }
  }
}

#Movement for nodes starting from right edge (5-9)
for {set t 0} {$t < 500} { incr t} {
  for {set i 5} {$i < 10 } { incr i } {
    set rnum [expr {rand()}]
    if {$rnum < 0.25} {
      $ns at expr{$t} "$node_($i) setdest 0.5 999.5 1.0"
    } elseif {$rnum < 0.5} {
      $ns at expr{$t} "$node_($i) setdest 0.5 750.0 1.0"
    } elseif {$rnum < 0.75} {
      $ns at expr{$t} "$node_($i) setdest 0.5 250.0 1.0"
    } else {
      $ns at expr{$t} "$node_($i) setdest 0.5 0.5 1.0"
    }
  }
}
#udp connection
set udp [new Agent/UDP]
$ns attach-agent $node_(0) $udp

set null0 [new Agent/Null]
$ns attach-agent $node_(9) $null0
$ns connect $udp $null0
# something new
$udp set fid_ 2

#generate cbr traffic
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp
$cbr0 set packetSize_ 500
$cbr0 set interval .005
$ns at 0.1 "$cbr0 start"


# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 90 defines the node size for nam
$ns initial_node_pos $node_($i) 200
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 500.0 "puts \"END OF AODV SIMULATION\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam simwrls.nam &
    #exec xgraph dsr_udp1.tr -geometry 800 * 400 &
    exit 0

}

$ns run

