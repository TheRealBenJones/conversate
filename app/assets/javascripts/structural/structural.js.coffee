#= require_self
#= require ./support/support
#= require ./flux/flux
#= require ./components/components
#
#= require_tree .

# We need exactly one top-level object so that tests and whatever
# can get access to our stuff.  Any other assignment to window. is
# probably an error.
window.Structural = {}
