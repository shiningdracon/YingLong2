import PackageDescription

let package = Package(
	name: "YingLong2",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mysql.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 1),
		.Package(url: "https://github.com/shiningdracon/SwiftGD.git", majorVersion: 1, minor: 4),
		.Package(url: "https://github.com/shiningdracon/OpenCC-swift.git", majorVersion: 1, minor: 0),
		.Package(url: "https://github.com/shiningdracon/BBCode-Swift.git", majorVersion: 0, minor: 4),
		.Package(url: "https://github.com/shiningdracon/ImageUploader.git", majorVersion: 1, minor: 1),
		.Package(url: "https://github.com/IBM-Swift/BlueCryptor.git", majorVersion: 0),
	]
)
