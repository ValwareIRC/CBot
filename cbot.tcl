proc ircsplit str {
	set res {}
	if {[string index $str 0] eq ":"} {
		lappend res [string range $str 1 [set first [string first " " $str]]-1]
		set str [string range $str 1+$first end]
	} else {
		lappend res {}
	}
	if {[set pos [string first " :" $str]] != -1} {
		lappend res {*}[split [string range $str 0 ${pos}-1]]
		lappend res [string range $str 2+$pos end]
	} else {
		lappend res {*}[split $str]
	}
	return $res
}

proc sockReadable {sockChan} {
	if {[eof $sockChan]} {
		close $sockChan
	}
	set line [gets $sockChan]
	set lline [ircsplit $line]
	puts ">> $lline"
	set chan [lindex $lline 2]
	set text [lindex $lline end]
	switch -nocase -- [lindex $lline 1] {
		PING {puts $sockChan "PONG :[lindex $lline 2]"}
		001 {puts $sockChan "JOIN #test"}
		PRIVMSG {switch -- [lindex $lline 3] {
				!quit {
					puts $sockChan "QUIT :Requested"
					close $sockChan
					return
				}
			}
		}
	}
}
set sockChan [socket -async $::server $::port]
fconfigure $sockChan -translation {auto crlf} -buffering line -blocking 0
puts $sockChan "NICK $::botnick"
puts $sockChan "USER $::ident * * :$::realname"
fileevent $sockChan readable [list sockReadable $sockChan]

# vwait forever -- don't use vwait in eggdrop
