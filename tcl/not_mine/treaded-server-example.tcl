#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

package require Tcl 8.4
package require Thread 2.5
if {$argc > 0} {
    set port [lindex $argv 0]
} else {
    set port 9001
}

socket -server _ClientConnect $port

proc _ClientConnect {sock host port} {
    # Tcl holds a reference to the client socket during
    # this callback, so we can't transfer the channel to our
    # worker thread immediately. Instead, we'll schedule an
    # after event to create the worker thread and transfer
    # the channel once we've re-entered the event loop.
    after 0 [list ClientConnect $sock $host $port]
}

proc ClientConnect {sock host port} {
    # Create a separate thread to manage this client. The
    # thread initialization script defines all of the client
    # communication procedures and puts the thread in its
    # event loop.
    set thread [thread::create {
        proc ReadLine {sock} {
            if {[catch {gets $sock line} len] || [eof $sock]} {
                catch {close $sock}
                thread::release
            } elseif {$len >= 0} {
                EchoLine $sock $line
            }
        }
        
        proc EchoLine {sock line} {
            if {[string equal -nocase $line quit]} {
                SendMessage $sock \
                "Closing connection to Echo server"
                catch {close $sock}
                thread::release
            } else {
                SendMessage $sock $line
            }
        }
        proc SendMessage {sock msg} {
            if {[catch {puts $sock $msg} error]} {
                puts stderr "Error writing to socket: $error"
                catch {close $sock}
                thread::release
            }
        }
        # Enter the event loop
        thread::wait
    }]
        
    # Release the channel from the main thread. We use
    # thread::detach/thread::attach in this case to prevent
    # blocking thread::transfer and synchronous thread::send
    # commands from blocking our listening socket thread.
    thread::detach $sock
    
    # Copy the value of the socket ID into the
    # client's thread
    thread::send -async $thread [list set sock $sock]
    
    # Attach the communication socket to the client-servicing
    # thread, and finish the socket setup.
    thread::send -async $thread {
        thread::attach $sock
        fconfigure $sock -buffering line -blocking 0
        fileevent $sock readable [list ReadLine $sock]
        SendMessage $sock "Connected to Echo server"
    }
}
set forever 1; vwait forever