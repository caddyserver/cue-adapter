// Copyright 2015 Matthew Holt and The Caddy Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cueadapter

import (
	"cuelang.org/go/cue"
	"github.com/caddyserver/caddy/v2/caddyconfig"
)

func init() {
	caddyconfig.RegisterAdapter("cue", Adapter{})
}

// Adapter adapts CUE to Caddy JSON.
type Adapter struct {
}

// Adapt converts the JSON5 config in body to Caddy JSON.
func (Adapter) Adapt(body []byte, options map[string]interface{}) ([]byte, []caddyconfig.Warning, error) {
	var rt cue.Runtime
	inst, err := rt.Compile("input.cue", body)
	if err != nil {
		return nil, nil, err
	}
	result, err := inst.Value().MarshalJSON()
	if err != nil {
		return nil, nil, err
	}
	return result, nil, nil
}

// Interface guard
var _ caddyconfig.Adapter = (*Adapter)(nil)
