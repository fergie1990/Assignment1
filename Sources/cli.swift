import Foundation
//implement WEXITSTATUS 
private func WEXITSTATUS(_ status: CInt) -> CInt {
	return (status >> 8) & 0xff
}
//read commands from standard input
func readStdin() -> String{
	let input: String? = readLine()
	var tmp: String = ""
	
	if input != nil {
	 tmp = input!
 }
	return tmp
}
//Use posix_spawnp to create a copy of the current process
func copyProcess() {
	//declare variables needed
	var input = String ()
	var argv = [String] ()
	var cmd = String ()
	//continue to read commands until user enters "exit"
	while cmd != "exit" {
		print("Please enter the command: ")
		//create array of arguments from standard input
		input = readStdin()
		argv = input.components(separatedBy: " ")
		cmd = argv[0]
		var cargv = argv.map { strdup($0) }
		cargv.append(nil)
		//free the memory of the array after the process is completed
		defer
		{
			for arg in cargv { free(arg) }
		}
		//create process ID for the new process
		var pid: pid_t = pid_t()
		//check if posix_spawnp return failed and print the error
		let returnVal: Int32 = posix_spawnp(&pid, cmd, nil, nil, cargv, nil)
		if returnVal != 0{
			let error: String = String(cString: strerror(returnVal))
			print("posix_spwnp failed with: \(error)")
			exit(EXIT_FAILURE)
		}
		//wait for the child process to end and return the error if one occurs
		var status: Int32 = 0
		let statusReturn = waitpid(pid, &status, 0)
		if statusReturn != -1 {
			print("Exit sataus: \(WEXITSTATUS(status))")
		}
	}
}
//use execvp to create a new process
func createProcess() {
	//get command line arguments from standard input
	print("Please enter the command: \n")
	let input: String = readStdin()
	let argv = input.components(separatedBy: " ")
	let cmd = argv[0]
	var cargv = argv.map { strdup($0) }
	cargv.append(nil)
	//free memory 
	defer
	{
		for arg in cargv { free(arg) }
		print("Memory was freed")
	}
	//get return value and check if failed
	let returnVal: Int32 = execvp(cmd, cargv)
	if returnVal == -1 {
		exit(EXIT_FAILURE)
	}
}

copyProcess()
//createProcess()
