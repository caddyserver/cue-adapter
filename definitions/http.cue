package caddy

Duration :: =~"^((\\d+)((n|u|m)?s|(m|h)))+$"

// --- Handlers ---
Authentication :: {
	HTTPBasic :: {
		BCrypt :: {
			algorithm: "bcrypt"
		}
		Scrypt :: {
			algorithm:  "scrypt"
			N:          uint
			r:          uint
			p:          uint
			key_length: uint
		}
		HashAlgorithm :: *BCrypt | Scrypt

		hash: HashAlgorithm
		accounts: [...{
			username: string
			password: string
			salt:     string
		}]
		realm: string | *"restricted"
	}

	handler: "authentication"
	providers: {
		http_basic: HTTPBasic
	}
}
Encode :: {
	Encoder :: {
		GzipEncoder :: {
			level: uint | *0
		}
		ZstdEncoder :: {}
		gzip?: GzipEncoder
		zstd?: ZstdEncoder
	}
	handler:         "encode"
	encodings:       Encoder
	minimum_length?: uint
}
Error :: {
	handler:     "error"
	error?:      string
	status_code: >=400 & <=600 | >=500
}
FileServer :: {
	handler: "file_server"
	root?:   string
	hide?: [...string]
	index_names?: [...string]
	browse?: {
		template_file?: string
	}
	canonical_uris?: bool
	pass_thru:       bool | false
}
Headers :: {
	HeaderReplace :: {
		search?:        string
		search_regexp?: string
		replace?:       string
	}

	handler: "headers"
	request?: {
		add?: [string]: [...string]
		set?: [string]: [...string]
		delete?: [...string]
		replace?: [string]: [...HeaderReplace]
	}
	response?: {
		add?: [string]: [...string]
		set?: [string]: [...string]
		delete?: [...string]
		replace?: [string]: [...HeaderReplace]
		require?: {
			status_code?: [...uint]
			headers?: [string]: [...string]
		}
		deferred?: bool
	}
}
RequestBody :: {
	handler:   "request_body"
	max_size?: uint
}

HTTPTransport :: {
	protocol: "http"
	tls?: {
		root_ca_pool?: [...string]
		root_ca_pem_files?: [...string]
		client_certificate_file?:     string
		client_certificate_key_file?: string
		insecure_skip_verify?:        bool
		handshake_timeout?:           uint | Duration
		server_name:                  string
	}
	keep_alive?: {
		enabled:                  bool
		probe_interval:           uint
		max_idle_conns?:          uint
		max_idle_conns_per_host?: uint
		idle_timeout?:            uint | Duration
	}
	compression?:              bool
	max_conns_per_host?:       uint
	dial_timeout?:             uint | Duration
	dial_fallback_delay?:      uint
	response_header_timeout?:  uint | Duration
	expect_continue_timeout?:  uint | Duration
	max_response_header_size?: uint
	write_buffer_size?:        uint
	read_buffer_size?:         uint
	versions?: [...string]
}
FastCGITransport :: {
	protocol: "fastcgi"
	root:     string
	split_path: [...string]
	env: [string]: string
	dial_timeout?:  uint | Duration
	read_timeout?:  uint | Duration
	write_timeout?: uint | Duration
}
Transport :: *HTTPTransport | FastCGITransport

FirstSelectionPolicy :: {
	policy: "first"
}
HeaderSelectionPolicy :: {
	policy: "header"
	field:  string
}
IPHashSelectionPolicy :: {
	policy: "ip_hash"
}
LeastConnSelectionPolicy :: {
	policy: "least_conn"
}
RandomSelectionPolicy :: {
	policy: "random"
}
RandomChooseSelectionPolicy :: {
	policy: "random_choose"
	choose: uint
}
RoundRobinSelectinPolicy :: {
	policy: "round_robin"
}
URIHashSelectionPolicy :: {
	policy: "uri_hash"
}
SelectionPolicy :: FirstSelectionPolicy | HeaderSelectionPolicy | IPHashSelectionPolicy | LeastConnSelectionPolicy | *RandomSelectionPolicy | RandomChooseSelectionPolicy | RoundRobinSelectinPolicy | URIHashSelectionPolicy
ReverseProxy :: {
	handler:   "reverse_proxy"
	transport: Transport
	circuit_breaker?: {
		type:       "internal"
		threshold?: uint
		factor:     *"latency" | "error_ratio" | "status_ratio"
		trip_time:  string | Duration | *"5s"
	}
	load_balancing?: {
		selection_policy?: SelectionPolicy
		try_duration?:     uint | Duration
		try_interval?:     uint | Duration
		retry_match?: [...Matcher]
	}
	HealthCheck :: {
		active?: {
			path: string
			port: uint
			headers: [string]: [...string]
			interval:      uint | Duration
			timeout:       uint | Duration
			max_size:      uint
			expect_status: uint
			expect_body:   string
		}
		passive?: {
			fail_duration?:          uint | Duration
			max_fails?:              uint
			unhealthy_request_count: uint
			unhealthy_status?: [...uint]
			unhealthy_latency?: uint
		}
	}
	health_checks?: HealthCheck
	upstreams: [...{
		dial:          string
		lookup_srv?:   string
		max_requests?: uint
	}]
	flush_interval?: uint | Duration
	headers?:        Headers
	buffer_requests: bool | *false
}
Rewrite :: {
	handler:            "rewrite"
	method?:            "GET" | "POST" | "HEAD" | "OPTIONS" | "DELETE" // TODO: other verbs
	uri?:               string
	strip_path_prefix?: string
	strip_path_suffix?: string
	uri_substring?: [...{
		find:    string
		replace: string
		limit:   uint
	}]
}
StaticResponse :: {
	handler:      "static_response"
	status_code?: string
	body:         string
	close?:       bool
}
Subroute :: {
	handler: "subroute"
	routes: [...Route]
	errors?: {
		routes: [...Route]
	}
}
Templates :: {
	handler:   "templates"
	file_root: string
	mime_types: [...string]
	delimiters: [...string]
}
Vars :: {
	handler:  "vars"
	[string]: string
}
Handler :: Authentication | Encode | Error | FileServer | Headers | RequestBody | Rewrite | ReverseProxy | StaticResponse | Subroute | Templates | Vars

// --- Matchers ---
Expression :: string
File :: {

	root?: string
	try_files?: [...string]
	try_policy?: *"first_exist" | "smallest_size" | "largest_size" | "most_recently_modified"
}
Header :: [string]: [...string]

HeaderRegexp :: [string]: [...{
	name?:   string
	pattern: string
}]

Host :: [...string]

Method :: [...string] // TODO: Should it be limited to the list of possible HTTP verbs?

Path :: [...string]

PathRegexp :: {
	name?:   string
	pattern: string
}

Protocol :: string

Query :: [string]: [...string]

RemoteIP :: {
	ranges: [...string]
}

VarsRegexp :: [string]: [...{
	name?:   string
	pattern: string
}]
Not :: {Matcher}
Matcher :: {
	exprssion?:     Expression
	file?:          File
	header?:        Header
	header_regexp?: HeaderRegexp
	host?:          Host
	method?:        Method
	path?:          Path
	path_regexp?:   PathRegexp
	protocol?:      Protocol
	query?:         Query
	remote_ip?:     RemoteIP
	vars_regexp?:   VarsRegexp
	not?:           Not
}

Route :: {
	group?: string
	match?: [...Matcher]
	handle: [...Handler]
	terminal?: bool
}

TLSWrapper :: {
	"wrapper": "tls"
}

ListenerWrapper :: TLSWrapper

HTTPServer :: {
	listen: [...string]
	listener_wrappers?: [...ListenerWrapper]
	read_timeout?:     uint | Duration
	write_timeout?:    uint | Duration
	idle_timeout?:     uint | Duration
	max_header_bytes?: uint
	routes: [...Route]
	errors?: {
		routes: [...Route]
	}
	tls_connection_policies?: [...TLSConnectionPolicy]
	automatic_https?: {
		disable?:           bool
		disable_redirects?: bool
		skip?: [...string]
		skip_certificates?: [...string]
		ignore_loaded_certificates?: bool
	}
	strict_sni_host?: bool
	logs?: {
		logger_names: {[string]: string}
	}
	experimental_http3?: bool
}

HTTPApp :: {
	http_port?:    uint
	https_port?:   uint
	grace_period?: uint | Duration
	servers: {[string]: HTTPServer}
}
