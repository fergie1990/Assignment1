import Foundation

var input: String? = readLine()
var tmp: String = ""

 while input != nil {
	 tmp = input!
	 if tmp == "exit" {
		 exit(EXIT_SUCCESS)
	 }
	 print(tmp)
	 input = readLine()
	 
 }
/*
let cmd: String = "ls"
let path: String = "/home/ben/Assignment1/Sources/"
let argv: [String] = [cmd, "-la", path]
var cargv = argv.map { strdup($0) }
cargv.append(nil)

defer
{
	for arg in cargv { free(arg) }
	print("Memory was freed")
}
 var pid: pid_t = pid_t()
let returnVal: Int32 = posix_spawnp(&pid, cmd, nil, nil, cargv, nil)
if returnVal != 0 {
	let error: String = String(cString: strerror(returnVal))
	print("posix_spawnp failed with: \(error)")
	exit(EXIT_FAILURE)
}
print("Complete")
*/