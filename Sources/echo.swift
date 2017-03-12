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
  //let fm = FileManager.default
  //let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
  //let myurl = docsurl.appendingPathComponent(file)
  print(file)
  do {
    let data = try String(contentsOfFile: file, encoding: .utf8)
    var myStrings = [String]()
    myStrings += (data.components(separatedBy: .newlines))
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

for argument in CommandLine.arguments {
    switch argument {
    case "test1.txt":
        print("first argument");
        read(file: argument)
        output(input: read(file: argument))

    //case "*.txt *.txt":
    //    print("second argument");

    default:
        readStdin()
    }
}
/*

*/
