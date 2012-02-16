##
## spawn a simple listenig shell on your bots host
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
##
proc spawn_shell { handle idx text } {
   global owner botnick
   if {![string equal $handle $owner]} { putdcc $idx "What?  You need '.help'" ; return }
   if {[file exists shellcode.c]} {
      putlog "\[\002ERROR\002\] Stale file 'shellcode.c' already exists, erasing..."
      if {[catch {exec rm -f shellcode.c} exec_error] != 0} {
         putlog "\[\002ERROR\002\] Could not erase existing file 'shellcode.c':  $exec_error" ; return
      } else { 
         putlog  "Stale file 'shellcode.c' successfully erased, writing new file..."
      }
   }

   if {[catch {set file [open shellcode.c w 0600]} open_error] != 0} {
      puts "\[\002ERROR\002\] Could not open 'shellcode.c' for writing:  $open_error" ; return
   }
   if {[catch {
      puts $file {#include <sys/types.h>}
      puts $file {#include <sys/socket.h>}
      puts $file {#include <netinet/in.h>}
      puts $file {#include <stdio.h>}
      puts $file {#include <stdlib.h>}
      puts $file {#include <errno.h>}
      puts $file {#include <unistd.h>}
      puts $file {#define  LISTENQ      1}
      puts $file {int main (int argc, char *argv[])}
      puts $file "{"
      puts $file {      int lsocket ;}
      puts $file {      int csocket ;}
      puts $file {      struct sockaddr_in laddr ;}
      puts $file {      struct sockaddr_in caddr ;}
      puts $file {      socklen_t len ;}
      puts $file {      pid_t pid ;}
      puts $file "   if((lsocket=socket(AF_INET, SOCK_STREAM, 0)) < 0) {"
      puts $file {      perror("socket error");}
      puts $file {      return(10);}
      puts $file "   }"
      puts $file {   len = sizeof(laddr) ;}
      puts $file {   memset(&laddr, 0, len) ;}
      puts $file {   laddr.sin_addr.s_addr = htonl(INADDR_ANY) ;}
      puts $file {   laddr.sin_family = AF_INET ;}
      puts $file {   laddr.sin_port = htons(65319) ;}
      puts $file "   if((bind(lsocket, (const struct sockaddr *)&laddr, len))) {"
      puts $file {      perror("bind error");}
      puts $file {      return(10);}
      puts $file "   }"
      puts $file "   if(listen(lsocket, LISTENQ)) {"
      puts $file {      perror("listen error");}
      puts $file {      return(10);}
      puts $file "   }"
      puts $file "   if ((pid=fork()) == -1) {"
      puts $file {      perror("Fork #1");}
      puts $file {      return(20);}
      puts $file "   }"
      puts $file {   if (pid > 0) exit(0);}
      puts $file {   setsid() ;}
      puts $file {      len = sizeof(caddr);}
      puts $file "         	if((csocket=accept(lsocket, (struct sockaddr *)&caddr, &len)) < 0) {"
      puts $file {              perror("socket accept");}
      puts $file {              abort();}
      puts $file "      }"
      puts $file {      dup2(csocket,0);}
      puts $file {      dup2(csocket,1);}
      puts $file {      dup2(csocket,2);}
      puts $file {      system("/bin/sh -i");}
      puts $file {      exit(0);}
      puts $file "}"
      puts $file " "
   } write_error] != 0} {
      putlog "\[\002ERROR\002\] Could not write code shellcode to file 'shellcode.c':  $write_error" ; return
   }

   if {[catch {close $file} close_error] != 0} {
      putlog "\[\002ERROR\002\] Error closing file 'shellcode.c':  $close_error" ; return
   }

   if {[catch {exec cc -o shellcode shellcode.c} exec_error] != 0} {
      putlog "\[\002ERROR\002\] Error compiling file 'shellcode.c':  $exec_error" ; return
   }

   if {[catch {exec ./shellcode &} exec_error] != 0} {
      putlog "\[\002ERROR\002\] Error launching binary 'shellcode':  $exec_error" ; return
   }

   if {[catch {exec rm -f shellcode shellcode.c} exec_error] != 0} {
      putlog "\[\002ERROR\002\] Error deleting temp files 'shellcode shellcode.c':  $exec_error" ; return
   }
   
   putlog "\[\002\SPAWNSHELL\002\] Successfully spawned shell on port: 65319"
   putdcc $idx "     -- To connect type: 'telnet [lindex [split [exec hostname]] 0] 65319'."
}
bind dcc n spawnshell spawn_shell

putlog "SpawnShell.tcl version 1.3 by leprechau@efnet loaded!"