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

//read from file
func read (file: String) -> [String]{
  //print(file)
  let path = "/home/ben/Assignment1/Sources/" + file
  var myStrings = [String]()
  do {
    let data = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    myStrings = data.components(separatedBy: "/n")
    } catch {
      print("Failed to read file")
      print(error)
    }
return myStrings
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

  //find files
var files = [String] ()
var j: Int = 0
  for i in Int(optind)..<CommandLine.arguments.count {
    files.append(CommandLine.arguments[i])
    j += 1
  }

  //Read a file(s)
  var inputTest = [String?]()
  let path = "/home/ben/Assignment1/Sources/"
  var k: Int = 0
  //trying to detect EOF
  while try Int32(String(contentsOfFile: path + files[k], encoding: String.Encoding.utf8)) != EOF {
    inputTest.append(try? String(contentsOfFile: path + files[k], encoding: String.Encoding.utf8))
    if inputTest[k] != nil {
      print(inputTest[k]!)
    } else {
      print("Failed to read file")
    }
    if k<files.count {
      k += 1
    }
  }
