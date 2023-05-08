import Foundation
import os.log

// Macros copied from <sys/wait.h>
fileprivate func _WSTATUS(_ value: Int32) -> Int32    { value & 0177 }
fileprivate func WIFEXITED(_ value: Int32) -> Bool    { _WSTATUS(value) == 0 }
fileprivate func WEXITSTATUS(_ value: Int32) -> Int32 { (value >> 8) & 0xff }

fileprivate typealias PipeDescriptor = Array<Int32>

@objc(HBCommand)
class Command: NSObject {

	enum ExecuteError: Error {
		case pipeFailed(code: errno_t)
		case spawnFailed(code: errno_t)
	}

	private static let logger = Logger(subsystem: "ws.hbang.common", category: "Command")

	private(set) var command = ""
	private(set) var arguments = [String]()

	private(set) var output = ""

	private var stdout: PipeDescriptor = [0, 0]

	@discardableResult
	@objc class func executeSync(_ command: String, arguments: [String]?, status: UnsafeMutablePointer<Int32>) -> String? {
		// As this method is intended for convenience, the arguments array isn’t expected to have the
		// first argument, which is typically the path or name of the binary being invoked. Add it now.
		let task = Command(command: command, arguments: [command] + (arguments ?? []))
		let result = try? task.executeSync()
		status.pointee = result ?? 127
		return result == 0 ? task.output : nil
	}

	init(command: String, arguments: [String]?) {
		super.init()
		self.command = command
		self.arguments = arguments ?? []
	}

	func executeSync() throws -> Int32 {
		// Create output and error pipes
		guard pipe(&stdout) != -1 else {
			throw ExecuteError.pipeFailed(code: errno)
		}

		// Convert our arguments array from Strings to char pointers
		let argv = arguments.map { strdup($0) }

		// Create our file actions to read data back from posix_spawn
		var actions: posix_spawn_file_actions_t!
		posix_spawn_file_actions_init(&actions)
		posix_spawn_file_actions_addclose(&actions, stdout[0])
		posix_spawn_file_actions_adddup2(&actions, stdout[1], STDOUT_FILENO)
		posix_spawn_file_actions_addclose(&actions, stdout[1])

		// Setup the dispatch queues for reading output and errors
		let lock = DispatchSemaphore(value: 0)
		let readQueue = DispatchQueue(label: "ws.hbang.common.command-read-queue",
																	qos: .default,
																	attributes: .concurrent)

		// Setup the dispatch handler for the output pipes
		let stdOutSource = DispatchSource.makeReadSource(fileDescriptor: stdout[0], queue: readQueue)
		stdOutSource.setEventHandler {
			let buffer = UnsafeMutableRawPointer.allocate(byteCount: Int(BUFSIZ), alignment: MemoryLayout<CChar>.alignment)
			let bytesRead = read(self.stdout[0], buffer, Int(BUFSIZ))
			switch bytesRead {
			case -1:
				let code = errno
				switch code {
				case EAGAIN, EINTR:
					// Ignore, we’ll be called again when the source is ready.
					break

				default:
					// Something is wrong; cancel the dispatch_source.
					stdOutSource.cancel()
					Self.logger.error("Command \(self.command) failed: \(code, format: .darwinErrno)")
				}

			case 0:
				// The fd was closed; cancel the dispatch_source.
				stdOutSource.cancel()

			default:
				// Read from output and notify delegate.
				if let chunk = String(bytesNoCopy: buffer, length: bytesRead, encoding: .utf8, freeWhenDone: false) {
					self.output += chunk
				}
			}
			buffer.deallocate()
		}
		stdOutSource.setCancelHandler {
			close(self.stdout[0])
			lock.signal()
		}
		stdOutSource.resume()

		// Spawn the child process
		var pid = pid_t()
		let spawnResult = posix_spawnp(&pid, command, &actions, nil, argv + [nil], nil)
		for item in argv {
			item?.deallocate()
		}

		if spawnResult != 0 {
			close(stdout[0])
			close(stdout[1])
			Self.logger.error("Command \(self.command) spawn failed: \(spawnResult, format: .darwinErrno)")
			throw ExecuteError.spawnFailed(code: errno_t(spawnResult))
		}

		// Close the write ends of the pipes so no odd data comes through them
		close(stdout[1])

		// Wait for the lock
		lock.wait()

		// Waits for the child process to terminate
		var status = Int32()
		waitpid(pid, &status, 0)

		// Get the true status code, if the process exited normally. If it died for some other reason,
		// we return the actual value we got back from waitpid(3), which should still be useful for
		// debugging what went wrong.
		return WIFEXITED(status) ? WEXITSTATUS(status) : status
	}

}
