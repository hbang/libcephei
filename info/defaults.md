# defaults(1): read and write preferences using Cephei
```
Usage:
  defaults read <id>                 Show all preferences for id.
  defaults read <id> <key>           Show value for preference key in id.
  defaults write <id> <key> <value>  Write value for preference key in id.
  defaults help                      Display this help.

Value is one of:
  <value> | -string <value>          String
  -int[eger] <value>                 Integer
  -float <value>                     Float
  -bool[ean] <value>                 Boolean

  Values not matching the specified type will be converted to an equivalent
  value in that type. Dictionary, array, data, and date values are not
  currently supported for writing through this tool.

Returns:
  0 on success. 1 on failure to read/write. 2 on invalid input.

Examples:
  defaults read com.apple.springboard
  defaults read com.apple.springboard SBBacklightLevel2
  defaults write -g AppleLocale en_US
  defaults write com.apple.springboard SBBacklightLevel2 -float 0.5
```
