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
	var index: Int = 0
	var in_cmd = [String] ()
	var out_cmd = [String] ()
	var out_flag: Bool = false
	
	var pipedes: [Int32] = [-1, -1]

	// first, creat the pipe
	guard pipe(&pipedes) != -1 else {
	    perror("pipe")
	    exit(EXIT_FAILURE)
	}

	//iterate each character in string
	for c in input.characters {
		//check for " and \
		///print(c)
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
				if out_flag == true {
					out_cmd.append(output[index])					
					print(out_cmd)
					//let file: FileHandle? = FileHandle(forUpdatingAtPath: "/home/ben/Assignment1/Sources/" + out_cmd[0])
					// let fd: [Int32] = [open(out_cmd[0], O_CREAT | O_RDWR, 0700)]
					// // then create the second child, running "sort -r"
					// print(fd[0])
					// if fd[0] == -1 {
					// 	print(errno)
					// }
					let pid2 = spawn(arguments: out_cmd, in_pipe: pipedes)
					guard pid2 != -1 else {
					    perror("ls")
					    close(pipedes[0])
					    close(pipedes[1])
					    exit(EXIT_FAILURE)
					}
					print(out_cmd)
					out_flag = false
				}
				index += 1
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
					print("test")
					//print("test8")
					tmpString = String(out_char)
					output.append(tmpString)
					let pid3 = spawn(arguments: output)
					guard pid3 != -1 else {
					    perror("ls")
					    close(pipedes[0])
					    close(pipedes[1])
					    exit(EXIT_FAILURE)
					}
					index += 1
					out_char.removeAll()
				//check for redirect output
			} else if c == "|" {
				print("out pipe")
					print(index)
					if out_char.count > 1 {
						tmpString = String(out_char)
						output.append(tmpString)
						
						index += 1
						out_char.removeAll()
						
					}
					in_cmd.append(output[index-1])
					print(in_cmd)
					//then create the first child, running "ls"
					let pid1 = spawn(arguments: in_cmd, out_pipe: pipedes)
					guard pid1 != -1 else {
					    perror("ls")
					    close(pipedes[0])
					    close(pipedes[1])
					    exit(EXIT_FAILURE)
					}
					
					
					out_flag = true
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
		/*
		 * the pipe is handed off to the children,
		 * so we should close the parent ends
		 */
		
	}
	if out_char.count > 1 && out_char[0] != " " {
		tmpString = String(out_char)
		output.append(tmpString)
		if out_flag == true {
			print("out")
			out_cmd.append(output[index])					
			print(out_cmd)
			let pid2 = spawn(arguments: out_cmd, in_pipe: pipedes)
			guard pid2 != -1 else {
					perror("ls")
					close(pipedes[0])
					close(pipedes[1])
					exit(EXIT_FAILURE)
			}
			print(out_cmd)
			out_flag = false
		}
		index += 1
	}
	//print(out_char)
	//print(in_char)
	print(output)
	return output
}

func spawn(arguments: [String], in_pipe: [Int32]? = nil, out_pipe: [Int32]? = nil, environment env: [UnsafeMutablePointer<CChar>?]? = nil) -> pid_t? {
    precondition(in_pipe  == nil || in_pipe!.count  == 2)
    precondition(out_pipe == nil || out_pipe!.count == 2)
    let environ = env ?? [nil]
#if os(macOS)
    var actions: posix_spawn_file_actions_t? = nil
    var attr: posix_spawnattr_t? = nil
#else
    var actions: posix_spawn_file_actions_t = posix_spawn_file_actions_t()
    var attr: posix_spawnattr_t = posix_spawnattr_t()
#endif
    posix_spawnattr_init(&attr)
    posix_spawn_file_actions_init(&actions)
    defer {
        posix_spawn_file_actions_destroy(&actions)
        posix_spawnattr_destroy(&attr)
    }
    if let inp = in_pipe {
        posix_spawn_file_actions_addclose(&actions, inp[1])
        posix_spawn_file_actions_adddup2(&actions, inp[0], STDIN_FILENO)
        posix_spawn_file_actions_addclose(&actions, inp[0])
    }
    if let outp = out_pipe {
        posix_spawn_file_actions_addclose(&actions, outp[0])
        posix_spawn_file_actions_adddup2(&actions, outp[1], STDOUT_FILENO)
        posix_spawn_file_actions_addclose(&actions, outp[1])
    }
    var pid: pid_t = 0
    let argv = arguments.map { strdup($0) } + [nil]
    defer { for arg in argv { free(arg) } }
		print(arguments[0])
		print(argv)
    let rv = posix_spawnp(&pid, arguments[0], &actions, &attr, argv, environ)
    if rv != 0 { perror("posix_spawnp") ; return nil }
		
		
    return pid
}

//Main
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
	//let pid1 = spawn(arguments: argv)
	
	// finally, wait for the children to exit
	repeat {
			var status = Int32(-1)
	#if os(macOS)
			let pid = wait(&status)
	#else
			let pid = withUnsafeMutablePointer(to: &status) {
					return wait(unsafeBitCast($0, to: __WAIT_STATUS.self))
			}
	#endif
	print(pid)
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
			print("pid")
	} while true
	print("complete")
	//copyProcess(cmd: cmd, argv: argv)
}
