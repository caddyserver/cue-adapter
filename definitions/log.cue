package caddy

FileWriter :: {
	output:           "file"
	filename:         string
	roll?:            bool
	roll_size_mb?:    uint
	roll_gzip?:       bool
	roll_local_time?: bool
	roll_keep?:       uint
	roll_keep_days?:  uint
}
NetWriter :: {
	output:  "net"
	address: string
}
StdxWriter :: {
	output: *"stdout" | "stderr" | "discard"
}
LoggingWriter :: FileWriter | NetWriter | *StdxWriter

DeleteFilterEncoder :: {
	filter: "delete"
}
IPMaskFilterEncoder :: {
	filter:     "ip_mask"
	ipv4_cidr:  uint8
	ipv6_cider: uint
}
FilterEncoderField :: DeleteFilterEncoder | IPMaskFilterEncoder

KeyedEncoder :: {
	format: "console" | *"json" | "logfmt"
} & {
	message_key?:     string
	level_key?:       string
	time_key?:        string
	name_key?:        string
	caller_key?:      string
	stacktrace_key?:  string
	line_ending?:     string
	time_format?:     string
	duration_format?: string
	level_format?:    string
}
FilterEncoder :: {
	format: "filter"
	wrap:   LoggingEncoder
	fields: FilterEncoderField
}
SingleFieldEncoder :: {
	format:   "single_field"
	field:    string
	fallback: LoggingEncoder
}
LoggingEncoder :: *KeyedEncoder | FilterEncoder | SingleFieldEncoder

Log :: {
	Logger :: {
		writer:  LoggingWriter
		encoder: LoggingEncoder
		level: "DEBUG" | *"INFO" | "WARN" | "ERROR" | "PANIC" | "FATAL"
		sampling?: {
			interval?:   uint
			first?:      uint
			thereafter?: uint
		}
		include?: [...string]
		exclude?: [...string]
	}
	sink?: {
		writer: LoggingWriter
	}
	logMap :: [string]: Logger
	logs: logMap & {
		default: {
			writer: {
				output: "stderr"
			}
			encoder: {
				format: "json"
			}
			level: "INFO"
			sampling: {
				interval: 1000000000 // 1 second
				first: 100
				thereafter: 100
			}
		}
	}
}
