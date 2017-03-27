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

//handle command line arguments
func cmdHandler(input: String) -> [String] {
	//declare variables
	var in_quotes: Bool = false 
	var escape: Bool = false
	var in_char = [Character] ()
	var out_char = [Character] ()
	var tmpString = String ()
	var output = [String] ()
	//iterate each character in string
	for c in input.characters {
		//check for "
		//print(c)
		if escape == false && c == "\"" || c == "\\" {
		//print("test1")
			if c == "\\" {
				//print("test2")
				escape = true
			} else if in_quotes == true {
				//print("test3")
				in_quotes = false
				tmpString = String(in_char)
				output.append(tmpString)
				in_char.removeAll()
			} else {
				//print("test4")
				in_quotes = true
			}
		//fill array	 
	} else if escape == true && c == "\"" || c == "\\" {
		if !in_char.isEmpty {
			//print("test5")
			in_char.append(c)
		} else {
			//print("test6")
			out_char.append(c)
		}
	} else {
			if in_quotes  {
				//print("test7")
				in_char.append(c)
			} else {
				//check for next argument
				if c == " " && out_char.count > 1 {
					//print("test8")
					tmpString = String(out_char)
					output.append(tmpString)
					out_char.removeAll()
					//out_char.append(c)
				} else if !out_char.isEmpty && out_char[0] == " " {
					//print("test9")
					out_char.remove(at: 0)
					out_char.append(c)
				} else {
					//print("test10")
					out_char.append(c)
				}
			}
		}
		//print(in_char)
		//print(out_char)
		if c != "\\" {
			escape = false
		}
	}
	if !out_char.isEmpty && out_char[0] != " " {
		tmpString = String(out_char)
		output.append(tmpString)
	}
	//print(out_char)
	//print(in_char)
	//print(output)
	return output
}

//Use posix_spawnp to create a copy of the current process
func copyProcess(cmd: String, argv: [String]) {
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


//declare variables needed
var input = String ()
var argv = [String] ()
var cmd = String ()
//continue to read commands until user enters "exit"
while cmd != "exit" {
	print("Please enter the command: ")
	//print(argv)
	//create array of arguments from standard input
	input = readStdin()
	argv = cmdHandler(input: input)
	cmd = argv[0]
	if cmd == "cd"{
		chdir(argv[1])
	}
	
	copyProcess(cmd: cmd, argv: argv)
}
