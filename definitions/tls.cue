package caddy

SerialNumber :: string

TLSConnectionPolicy :: {
	match?: {
		sni?: [...string]
	}
	certificate_selection?: {
		serial_number?: [...SerialNumber]
		subject_organization?: [...string]
		public_key_algorithm?: uint
		any_tag?: [...string]
		all_tags?: [...string]
	}
	cipher_suites?: [...string]
	curves?: [...string]
	alpn?: [...string]
	protocol_min?: *"tls1.2" | "tls1.3"
	protocol_max?: "tls1.2" | *"tls1.3"
	client_authentication?: {
		trusted_ca_certs?: [...string]
		trusted_leaf_certs?: [...string]
		mode?: "request" | "require" | "verify_if_given" | *"require_and_verify"
	}
	default_sni?: string
}

TLSApp :: {

	automateCerts :: [...string] | *[""]
	loadFiles :: [...{
		certificate: string
		key:         string
		format:      string | *"pem"
		tags: [...string]
	}]
	loadFolders :: [...string]
	loadPEM :: [...{
		certificate: string
		key:         string
		tags: [...string]
	}]
	certificates: {
		automate:      automateCerts
		load_files?:   loadFiles
		load_folders?: loadFolders
		load_pem?:     loadPEM
	}
	automation: {
		internalIssuer :: {
			module:         "internal"
			ca:             string | "local"
			lifetime:       Duration
			sign_with_root: bool
		}
		acmeIssuer :: {
			module:  "acme"
			ca:      string
			test_ca: string
			email:   string
			external_account?: {
				key_id: string
				hmac:   string
			}
			acme_timeout: Duration
			challenges: {
				http: {
					disabled:       bool
					alternate_port: uint
				}
				"tls-alpn": {
					disabled:       bool
					alternate_port: uint
				}
			}
			trusted_roots_pem_files: [...string]
		}
		policies: [...{
			subjects: [...string]
			issuer: {

			}
			must_stable:          bool | *false
			renewal_window_ratio: uint
			key_type:             "ed25519" | "p256" | "p384" | "rsa2048" | "rsa4096"
			storage:              Storage
			on_demand:            bool
		}]
		on_demand: {
			rate_limit: {
				interval: uint
				burst:    uint
			}
			ask: string
		}
		ocsp_interval:   Duration
		renew_intervall: Duration
	}

	standardKeySource :: {
		provider: "standard"
	}
	distributedKeySource :: {
		provider: "distributed"
		storage:  Storage
	}
	KeySource :: *standardKeySource | distributedKeySource

	session_tickets: {
		key_source:        KeySource
		rotation_interval: Duration
		max_keys:          uint | *4
		disable_rotation:  bool | *false
		disabled:          bool | *false
	}
}
