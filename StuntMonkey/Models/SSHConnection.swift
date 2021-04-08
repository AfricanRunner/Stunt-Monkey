
import Foundation

let command = Command(host: "localhost", port: 22)

command.connect()
       .authenticate(.byPassword(username: "username", password: "password"))
       .execute(command) { (command, result: String?, error) in
           if let result = result {
               print("\(result)")
           } else {
               print("ERROR: \(error)")
           }
       }
