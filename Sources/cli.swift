import Foundation

//implement WEXITSTATUS 
func wExitStatus(value: Int32) -> Int { 
	return Int((value >> 8) & 0xff) 
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
		print(c)
		if c == "\"" || c == "\\" {
		print("test1")
			if c == "\\" {
				print("test2")
				if escape == true {
					if in_quotes == true {
						print("test3")
						in_char.append(c)
					} else {
						print("test4")
						out_char.append(c)
					} 
					escape = false
				} else {
					escape = true
				}
		} else if in_quotes == true {
			//print("test3")
			if escape == false {
				in_quotes = false
				tmpString = String(in_char)
				output.append(tmpString)
				in_char.removeAll()
			} else {
				in_char.append(c)
			}
		} else {
			//print("test4")
			in_quotes = true
		}
	//fill array	 
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
		print(out_char)
		if c != "\\" {
			escape = false
		} 
	}
	print(output)
	if out_char.count > 1 && out_char[0] != " " {
		tmpString = String(out_char)
		output.append(tmpString)
	}
	//print(out_char)
	//print(in_char)
	//print(output)
	return output
}

func spawn(arguments: [String], in_pipe: [Int32]? = nil, out_pipe: [Int32]? = nil, environment env: [UnsafeMutablePointer<CChar>?]? = nil) -> pid_t? {
    precondition(in_pipe  == nil || in_pipe!.count  == 2)
    precondition(out_pipe == nil || out_pipe!.count == 2)
    let environ = env ?? [nil]
    var actions: posix_spawn_file_actions_t? = nil
    var attr: posix_spawnattr_t? = nil
    posix_spawnattr_init(&attr!)
    posix_spawn_file_actions_init(&actions!)
    defer {
        posix_spawn_file_actions_destroy(&actions!)
        posix_spawnattr_destroy(&attr!)
    }
    if let inp = in_pipe {
        posix_spawn_file_actions_addclose(&actions!, inp[1])
        posix_spawn_file_actions_adddup2(&actions!, inp[0], STDIN_FILENO)
        posix_spawn_file_actions_addclose(&actions!, inp[0])
    }
    if let outp = out_pipe {
        posix_spawn_file_actions_addclose(&actions!, outp[0])
        posix_spawn_file_actions_adddup2(&actions!, outp[1], STDOUT_FILENO)
        posix_spawn_file_actions_addclose(&actions!, outp[1])
    }
    var pid: pid_t = 0
    let argv = arguments.map { strdup($0) } + [nil]
    defer { for arg in argv { free(arg) } }
    let rv = posix_spawnp(&pid, arguments[0], &actions!, &attr!, argv, environ)
    if rv != 0 { perror("posix_spawnp") ; return nil }
    return pid
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
		print("Exit sataus: \(wExitStatus(value: status))")
	}
}



//declare variables needed
var input = String ()
var argv = [String] ()
var cmd = String ()

var pipedes: [Int32] = [-1, -1]

// first, creat the pipe
guard pipe(&pipedes) != -1 else {
    perror("pipe")
    exit(EXIT_FAILURE)
}

// then create the first child, running "ls"
let pid1 = spawn(arguments: ["ls"], out_pipe: pipedes)
guard pid1 != -1 else {
    perror("ls")
    close(pipedes[0])
    close(pipedes[1])
    exit(EXIT_FAILURE)
}

// then create the second child, running "sort -r"
let pid2 = spawn(arguments: ["sort", "-r"], in_pipe: pipedes)
guard pid2 != -1 else {
    perror("ls")
    close(pipedes[0])
    close(pipedes[1])
    exit(EXIT_FAILURE)
}

/*
 * the pipe is handed off to the children,
 * so we should close the parent ends
 */
close(pipedes[0])
close(pipedes[1])

// finally, wait for the children to exit
repeat {
    var status = Int32(-1)
    let pid = wait(&status)
    if pid == -1 {
        switch errno {
            case EAGAIN: fallthrough
            case EINTR:
                continue
            case ECHILD:
                exit(EXIT_SUCCESS)
            default:
                perror("wait")
                exit(EXIT_FAILURE)
        }
    } else if pid == 0 { break }

    let rv = wExitStatus(value: status)
    if rv != 0 {
        fputs("\(CommandLine.arguments[0]): child \(pid) exited with code \(rv)\n", stderr)
    }
} while true

//continue to read commands until user enters "exit"
// while cmd != "exit" {
// 	print("Please enter the command: ")
// 	//print(argv)
// 	//create array of arguments from standard input
// 	input = readStdin()
// 	argv = cmdHandler(input: input)
// 	cmd = argv[0]
// 	if cmd == "cd"{
// 		chdir(argv[1])
// 	}
// 	
// 	//copyProcess(cmd: cmd, argv: argv)
// }
