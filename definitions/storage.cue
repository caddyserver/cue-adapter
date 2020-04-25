package caddy

FilesystemStorage :: {
	module: "filelsystem"
	root?:  string
}

Storage :: FilesystemStorage
