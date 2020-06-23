# NimbleOptionsType

This was an experiment to automatically generate Dialyzer type specifications for [nimble_options](https://github.com/dashbitco/nimble_options). While it is possible in general, macro code would have to be a bit complicated in order to support recursive types. Another major flaw is the fact that NimbleOptions uses keyword lists instead of maps: for keyword lists, it is not possible to specify in Dialyzer type specs whether a field is required or optional.
