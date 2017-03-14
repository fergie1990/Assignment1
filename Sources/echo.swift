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
func readFiles(files: [String]) -> [String] {
  let path = "/home/ben/Assignment1/Sources/"
  var myStrings = [String]()
  var data = String ()
  for index in 0..<files.count {
    do {
      data = try String(contentsOfFile: path + files[index], encoding: String.Encoding.utf8)
      myStrings += (data.components(separatedBy: "\n"))
    } catch {
      print("Failed to read file")
      print(error)
    }
  }
  return myStrings
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
var lines = readFiles(files: files)
if nFlag == true || bFlag == true{
  var nlines = numberLines(lines: lines, bflag: bFlag)
  output(input: nlines)
}
if sFlag == true {
  var slines = squeezeLines(lines: lines)
  output(input: slines)
}

