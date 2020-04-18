package caddy

Admin :: {
	disabled:       bool | *false
	listen:         string | *"localhost:2019"
	enforce_origin: bool | *false
	origins?: [...string]
	config: {
		persist: bool | *true
	}
}

App :: {
	http?: HTTPApp
	pki?:  PKIApp
	tls?:  TLSApp
}

Config :: {
	admin:    Admin
	logging?: Log
	storage?: Storage
	apps:     App
}
