import Foundation


/*while line != eof {
  line += readLine()!
  print(line)
}*/

func getLines () -> [String] {

  var i : Int = 0
  var lines = [String] ()
  var line : String = ""
  let eof = "^Z"
  lines.append("")
  print(EOF)
  while lines[i] != eof {
    print(i)
    line = readLine()!
    lines.append(line)
    i += 1
  }
  return lines
}

func printLine(input: [String]) {
  for var i in 0..<input.count {
    print(input[i])
    i += 1
  }
}

var lines = [String] (getLines())
printLine(input: lines)
