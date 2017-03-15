import Foundation

//read from stdin complete
func readStdin() {

  var line : String? = ""
  line = readLine()

  while line != nil {
    print(line!)
    line = readLine()
  }
}
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
        numberedLines.append(String(index) + "  " + lines[index])
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
func nonPrinting(lines: [String]) -> [String]{
  /*var myString = [String] ()
  let control: Int8 = 1
  var controlChar: Int8 = 1
  print(lines)
  for i in 0..<lines.count {
    let nonPrintLines = lines.map { strdup($0) }
    if nonPrintLines.load(as: UInt8.self) >= 1 && nonPrintLines.load(as: UInt8.self).value < 32 {
      controlChar = nonPrintLines + control
      print(controlChar)
    }
  }
  */
	var newlines = lines
	var catCharacters = [Character] ()
	var catString = String ()
	let control: UnicodeScalar = "@"
	let controlVal: UInt32 = control.value
	var controlChar: Int = 1
	var myString = [String] ()
  for index in 0..<lines.count {
		catCharacters.removeAll()
		newlines[index].append("\n")
    for character in newlines[index].unicodeScalars {
      if character.value >= 1 && character.value < 32 {
        controlChar = Int(character.value) + Int(controlVal)
				//print("^\(Character(UnicodeScalar(controlChar)!))")
				catCharacters.append("^")
				catCharacters.append(Character(UnicodeScalar(controlChar)!))
      } else {
        //print(character)
				catCharacters.append(Character(character))
      }
			
    }
		//print(catCharacters)
    catString = String(catCharacters)
		//print(catString)
		//print(myString[index])
		myString.append(catString) 
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
for index in 0..<files.count {
  myString = readFiles(file: files[index])
  if nFlag == true || bFlag == true{
    myString = numberLines(lines: myString, bflag: bFlag)
    //output(input: nlines)
  }
  if sFlag == true {
    myString = squeezeLines(lines: myString)
    //output(input: slines)
  }
  if vFlag == true || tFlag == true || eFlag == true{
    myString = nonPrinting(lines: myString)
  }
}
output(input: myString)