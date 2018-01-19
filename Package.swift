import PackageDescription

let package = Package(
	name: "Lua",
	dependencies: [
		.Package(url: "https://github.com/Zig1375/CLua.git", majorVersion: 0, minor: 1)
	]
)