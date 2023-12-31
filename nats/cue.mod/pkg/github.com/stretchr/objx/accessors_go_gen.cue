// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/stretchr/objx

package objx

// PathSeparator is the character used to separate the elements
// of the keypath.
//
// For example, `location.address.city`
#PathSeparator: "."

// arrayAccesRegexString is the regex used to extract the array number
// from the access path
_#arrayAccesRegexString: "^(.+)\\[([0-9]+)\\]$" // `^(.+)\[([0-9]+)\]$`

// mapAccessRegexString is the regex used to extract the map key
// from the access path
_#mapAccessRegexString: "^([^\\[]*)\\[([^\\]]+)\\](.*)$" // `^([^\[]*)\[([^\]]+)\](.*)$`
