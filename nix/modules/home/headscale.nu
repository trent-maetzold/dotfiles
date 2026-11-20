# Completions for the `headscale` wrapper (ssh heimdall). Nushell's external
# completer is carapace, which has no headscale support, so ask the remote
# binary's cobra completion endpoint instead. bash/zsh/fish use the generated
# scripts shipped by the headscale package, which do the same thing.
def "nu-complete headscale" [place?: record] {
  let words = (
    if ($place | describe) =~ 'record' {
      $place.command? | default []
    } else {
      []
    }
  )
  let args = (if ($words | length) > 1 { $words | skip 1 } else { [""] })
  let out = (^headscale __complete ...$args | complete)

  $out.stdout
  | lines
  | where {|line| not ($line | str starts-with ':') }
  | each {|line|
      let parts = ($line | split row "\t")
      if ($parts | length) > 1 {
        {value: $parts.0, description: ($parts | skip 1 | str join ' ')}
      } else {
        $parts.0
      }
    }
}

extern headscale [...args: string@"nu-complete headscale"]
