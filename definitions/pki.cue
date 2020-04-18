package caddy

Cert :: {
	certificate: string
	private_key: string
	format:      string
}

CertificateAuthority :: {
	name:                     string
	root_common_name:         string
	intermediate_common_name: string
	install_trust:            bool
	root?:                    Cert
	intermediate?:            Cert
	storage:                  Storage
}

PKIApp :: {
	"certificate_authorities": [string]: CertificateAuthority
}
