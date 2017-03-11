import Foundation

let eof = "^Z"
var line: String = ""

while line != eof {
  line = readLine()!
  print(line)
}
