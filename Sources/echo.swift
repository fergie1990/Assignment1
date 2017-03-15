import Foundation
/*
//read from stdin complete
func readStdin() {

  var line = String? ()
  line = readLine()

  while line != nil {
    print(line!)
    line = readLine()
  }
}
*/
//find files
func findFiles() -> [String] {
  var files = [String] ()
  var j: Int = 0
  for i in Int(optind)..<CommandLine.arguments.count {
    files.append(CommandLine.arguments[i])
    j += 1
  }
  return files
}


//Read a file(s)
func readFiles(file: String) -> [String] {
  let path = "/home/ben/Assignment1/Sources/"
  var myString = [String] ()
  do {
    let data = try String(contentsOfFile: path + file, encoding: String.Encoding.utf8)
    myString += (data.components(separatedBy: "\n"))
  } catch {
    print("Failed to read file")
    print(error)
  }
  return myString
}

func numberLines(lines: [String], bflag: Bool) -> [String] {
  var numberedLines = [String] ()
  var count: Int = 1
  for index in 0..<lines.count {
    if bflag == true && lines[index] == "" {
      numberedLines.append(lines[index])
    } else if bflag == true && lines[index] != "" {
        numberedLines.append(String(count) + "  " + lines[index])
        count += 1
    } else {
        numberedLines.append(String(index + 1) + "  " + lines[index])
    }
  }
  return numberedLines
}

func squeezeLines(lines: [String]) -> [String] {
  var squeezedLines = lines
  //counting the squeezed lines
  var scount: Int = 0
  for index in 1..<lines.count {
    if lines[index-1] == "" && lines[index] == ""{
      squeezedLines.remove(at: index - scount)
      scount += 1
    }
  }
  return squeezedLines
}

//show non printing
func nonPrinting(lines: [String], tflag: Bool, eflag: Bool) -> [String] {
	var newlines = lines
	var catCharacters = [Character] ()
	var catString = String ()
	let control: UnicodeScalar = "@"
	let controlVal: UInt32 = control.value
	var controlChar: Int = 1
	var myString = [String] ()
  for index in 0..<lines.count {
		catCharacters.removeAll()
		if tflag == true {
			newlines[index].append("\n")
		}
    for character in newlines[index].unicodeScalars {
      if character.value >= 1 && character.value < 32 && tflag == true {
        controlChar = Int(character.value) + Int(controlVal)
				catCharacters.append("^")
				catCharacters.append(Character(UnicodeScalar(controlChar)!))
      } else if character.value >= 1 && character.value < 32 && character.value != 9 && character.value != 10 && tflag == false{
				controlChar = Int(character.value) + Int(controlVal)
				catCharacters.append("^")
				catCharacters.append(Character(UnicodeScalar(controlChar)!))
			} else {
				catCharacters.append(Character(character))
      }			
    }
		if eflag == true {
			catCharacters.insert("$", at: catCharacters.count)
		}
    catString = String(catCharacters)
		myString.append(catString) 
  }
return myString
}

//checkflags
func checkFlags(line: [String], nflag: Bool, bflag: Bool, sflag: Bool, vflag: Bool, tflag: Bool, eflag: Bool) -> [String] {
	var myString: [String] = line
	if vflag == true || tflag == true || eflag == true{
		myString = nonPrinting(lines: myString, tflag: tflag, eflag: eflag)
	}
	if sflag == true {
		myString = squeezeLines(lines: myString)
		//output(input: slines)
	}
	if nflag == true || bflag == true{
		myString = numberLines(lines: myString, bflag: bflag)
		//output(input: nlines)
	}
	
	return myString
}

//print file contents
func output(input: [String]) {
  for var i in 0..<input.count {
    print(input[i])
    i += 1
  }
}

  var nFlag: Bool = false
  var bFlag: Bool = false
  var sFlag: Bool = false
  var vFlag: Bool = false
  var tFlag: Bool = false
  var eFlag: Bool = false
  //retrieve options
  var option = getopt(CommandLine.argc, CommandLine.unsafeArgv, "nbsvte")
  while option != -1 {
    switch UnicodeScalar(CUnsignedChar(option)) {
    case "n":
      nFlag = true
    case "b":
      bFlag = true
    case "s":
      sFlag = true
    case "v":
      vFlag = true
    case "t":
      tFlag = true
    case "e":
      eFlag = true
    default:
      print("Bad option found")
    }
    option = getopt(CommandLine.argc, CommandLine.unsafeArgv, "nbsvte")
  }

var files = findFiles()
var myString = [String] ()

var input = [String?] ()
var count: Int = 0

if files.isEmpty == false {
	for index in 0..<files.count {
	  myString = readFiles(file: files[index])
	  myString = checkFlags(line: myString, nflag: nFlag, bflag: bFlag, sflag: sFlag, vflag: vFlag, tflag: tFlag, eflag: eFlag)
		output(input: myString)
	}
} else {
	sFlag = false
  input.insert(readLine(), at: 0)
	var line: [String] =  [input[0]!]
	//print(line)
  while input[count] != nil {
    line = checkFlags(line: line, nflag: nFlag, bflag: bFlag, sflag: sFlag, vflag: vFlag, tflag: tFlag, eflag: eFlag)
		print(line[count])
		//line.removeAll()
		count += 1
    input.insert(readLine(), at: count)
		line = input.flatMap{ $0 }
		
	}
}