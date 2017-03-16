import Foundation

func readStdin() -> String{
	let input: String? = readLine()
	var tmp: String = ""
	
	if input != nil {
	 tmp = input!
	 if tmp == "exit" {
		 exit(EXIT_SUCCESS)
	 }
	}
	return tmp
}
print("Please enter the command: \n")
let input: String = readStdin()
let argv = input.components(separatedBy: " ")
let cmd = argv[0]
var cargv = argv.map { strdup($0) }
cargv.append(nil)

defer
{
	for arg in cargv { free(arg) }
	print("Memory was freed")
}

let returnVal: Int32 = execvp(cmd, cargv)
if returnVal == -1 {
	print("failure")
	exit(EXIT_FAILURE)
}

print("Complete")
/*
var pid: pid_t = pid_t()
let returnVal: Int32 = posix_spawnp(&pid, cmd, nil, nil, cargv, nil)
if returnVal != 0 {
	let error: String = String(cString: strerror(returnVal))
	print("posix_spawnp failed with: \(error)")
	exit(EXIT_FAILURE)
}
*/
