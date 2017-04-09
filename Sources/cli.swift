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
func inputHandler(input: String) -> [String] {
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
		if c == "\"" || c == "\\" {
			if c == "\\" {
				if escape == true {
					if in_quotes == true {
						in_char.append(c)
					} else {
						out_char.append(c)
					} 
					escape = false
				} else {
					escape = true
				}
		} else if in_quotes == true {
			if escape == false {
				in_quotes = false
				tmpString = String(in_char)
				output.append(tmpString)
				in_char.removeAll()
			} else {
				in_char.append(c)
			}
		} else {
			in_quotes = true
			if out_char.count > 0 {
				tmpString = String(out_char)
				output.append(tmpString)
				out_char.removeAll()
			}
		}
	//fill array	 
	} else {
			if in_quotes  {
				in_char.append(c)
			} else {
				//check for next argument
				if c == " "{
					if out_char.count > 0 {
						tmpString = String(out_char)
						output.append(tmpString)
						out_char.removeAll()
					}
				} else if c == "|" || c == ">" || c == "<" || c == ";"{
					if out_char.count > 0 {
						tmpString = String(out_char)
						output.append(tmpString)
						out_char.removeAll()
					}
					output.append(String(c))
				} else {
					out_char.append(c)
				}
			}
		}
		if c != "\\" {
			escape = false
		} 
	}
	if out_char.count > 1 && out_char[0] != " " {
		tmpString = String(out_char)
		output.append(tmpString)
	}
	print(output)
	return output
}

func cmdHandler(arguments: [String]) {
	//declare variables
	var pipedes: [Int32] = [-1, -1]
	var pipedes2: [Int32] = [-1, -1]
	//var tmpargv1 = [String] ()
	var tmpargv2 = [String] ()
	//var in_flag: Bool = false
	var out_flag: Bool = false
	var inout_flag: Bool = false
	var redirout_flag: Bool = false
	var redirin_flag: Bool = false
	let mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
	// first, creat the pipe
	guard pipe(&pipedes) != -1 else {
			perror("pipe")
			exit(EXIT_FAILURE)
	}
	guard pipe(&pipedes2) != -1 else {
			perror("pipe")
			exit(EXIT_FAILURE)
	}
	print(pipedes)
	print(pipedes2)
	defer {
		/*
		 * the pipe is handed off to the children,
		 * so we should close the parent ends
		 */
		 close(pipedes[0])
 		 close(pipedes[1])	
		 close(pipedes2[0])
 		 close(pipedes2[1])		
	}
	for var i in 0..<arguments.count {
		//print(i)
		if arguments[i] == "|" || arguments[i] == ">" || arguments[i] == "<" {
			//print("test1")
			//print(pipedes)
			if inout_flag == false {
				//checking if it is the first pipe
				if out_flag == false {
					out_flag = true
						if arguments[i] == "|" {
							print("test1")
							// then create the first child, running "ls"
							let pid1 = spawn(arguments: tmpargv2, out_pipe: pipedes)
							guard pid1 != -1 else {
								perror("ls")
								close(pipedes[0])
								close(pipedes[1])
								exit(EXIT_FAILURE)
							}
							tmpargv2.removeAll()
						} else if arguments[i] == ">" {
							redirout_flag = true
						} else {
							redirin_flag = true
						}
				} else {
					//print("inout")
					if arguments[i] == ">" {
						//print("redir")
						redirout_flag = true
					} else {
						print("test2")
						// then create the second child, running "sort -r"
						let pid2 = spawn(arguments: tmpargv2, in_pipe: pipedes, out_pipe: pipedes2)
						guard pid2 != -1 else {
							perror("ls")
							close(pipedes[0])
							close(pipedes[1])
							exit(EXIT_FAILURE)
						}
						tmpargv2.removeAll()
					}
					inout_flag = true
				}
			} else {
				//print("test2")
				// then create the second child, running "sort -r"
				let pid3 = spawn(arguments: tmpargv2, in_pipe: pipedes, out_pipe: pipedes2)
				guard pid3 != -1 else {
					perror("ls")
					close(pipedes[0])
					close(pipedes[1])
					exit(EXIT_FAILURE)
				}
				tmpargv2.removeAll()
			}
		} else if inout_flag == true && redirout_flag == true {
			tmpargv2.append(arguments[i])
			//print(pipedes)
			//print(tmpargv2)
			pipedes2[1] = open(tmpargv2[tmpargv2.count-1], O_RDWR | O_CREAT | O_TRUNC, mode)
			//print(pipedes)
			tmpargv2.remove(at: tmpargv2.count-1)
			// then create the second child, running "sort -r"
			let pid4 = spawn(arguments: tmpargv2, in_pipe: pipedes, out_pipe: pipedes2)
			guard pid4 != -1 else {
				perror("ls")
				close(pipedes[0])
				close(pipedes[1])
				exit(EXIT_FAILURE)
			}
			tmpargv2.removeAll() 
		} else if redirout_flag == true {
			tmpargv2.append(arguments[i])
			//print(pipedes)
			//print(tmpargv2)
			pipedes[1] = open(tmpargv2[tmpargv2.count-1], O_RDWR | O_CREAT | O_TRUNC, mode)
			//print(pipedes)
			tmpargv2.remove(at: tmpargv2.count-1)
			// then create the second child, running "sort -r"
			let pid5 = spawn(arguments: tmpargv2, out_pipe: pipedes)
			guard pid5 != -1 else {
				perror("ls")
				close(pipedes[0])
				close(pipedes[1])
				exit(EXIT_FAILURE)
			}
			tmpargv2.removeAll()
		} else if redirin_flag == true {
			//print("redirin")
			tmpargv2.append(arguments[i])
			//print(pipedes)
			//print(tmpargv2[tmpargv2.count-1])
			pipedes[0] = open(tmpargv2[tmpargv2.count-1], O_RDWR)
			//print(pipedes)
			tmpargv2.remove(at: tmpargv2.count-1)
			// then create the second child, running "sort -r"
			let pid5 = spawn(arguments: tmpargv2, in_pipe: pipedes)
			guard pid5 != -1 else {
				perror("ls")
				close(pipedes[0])
				close(pipedes[1])
				exit(EXIT_FAILURE)
			}
			tmpargv2.removeAll()
		}else {
			tmpargv2.append(arguments[i])
		}
		i += 1
	}
	if out_flag == false {
		//print("no pipe")
		//print(tmpargv2)
		let pid6 = spawn(arguments: tmpargv2)
		guard pid6 != -1 else {
				perror("ls")
				close(pipedes[0])
				close(pipedes[1])
				exit(EXIT_FAILURE)
		}
		tmpargv2.removeAll()
	}
	if inout_flag == true && redirout_flag == false && redirin_flag == false{
		print("test3")
		let pid7 = spawn(arguments: tmpargv2, in_pipe: pipedes2)
		guard pid7 != -1 else {
				perror("ls")
				close(pipedes[0])
				close(pipedes[1])
				exit(EXIT_FAILURE)
		}
		tmpargv2.removeAll()
	}
}

func spawn(arguments: [String], in_pipe: [Int32]? = nil, out_pipe: [Int32]? = nil, environment env: [UnsafeMutablePointer<CChar>?]? = nil) -> pid_t? {
    print("spawn")
		print(arguments)
		if in_pipe != nil {
			print("in")
			print(in_pipe!)
		}
		if out_pipe != nil {
			print("out")
			print(out_pipe!)
		}
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
    let rv = posix_spawnp(&pid, arguments[0], &actions, &attr, argv, environ)
    if rv != 0 { perror("posix_spawnp") ; return nil }
    return pid
}

//declare variables needed
var input = String ()
var argv = [String] ()
var tmpargv1 = [String] ()
var cmd = String ()
defer {
	//print("waiting")
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
}
//continue to read commands until user enters "exit"
while cmd != "exit" {
	print("Please enter the command: ")
	//print(argv)
	//create array of arguments from standard input
	input = readStdin()
	argv = inputHandler(input: input)
	cmd = argv[0]
	if cmd == "cd"{
		chdir(argv[1])
	}
	//print(argv.count - 1)
	for var j in 0..<argv.count {
		//print(j)
		if argv[j] != ";" && j != argv.count - 1 {
			tmpargv1.append(argv[j])
			//print(tmpargv1)
		} else if argv[j] != ";" && j < argv.count - 1{
			tmpargv1.append(argv[j])
		} else if j == argv.count - 1 {
				tmpargv1.append(argv[j])
				//print("program found")
				//print(tmpargv1)
				cmdHandler(arguments: tmpargv1)
				tmpargv1.removeAll()
		} else {
				//print("program found")
				//print(tmpargv1)
				cmdHandler(arguments: tmpargv1)
				tmpargv1.removeAll()
		}
	}
}