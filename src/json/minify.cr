require "string_scanner"
require "json"
require "./errors"
require "./version"

# TODO: Write documentation for `JSON::Minify`
module JSON
  module Minify
    def minify(str)
      ss = StringScanner.new(str)
      buf = ""

      until ss.eos?
        # Remove whitespace
        if s = ss.scan(/\s+/)
          next
        # Scan punctuation
        elsif s = ss.scan(/[{},:\]\[]/)
          buf += s

        # Scan strings
        elsif s = ss.scan(/""|(".*?[^\\])?"/)
          buf += s

        # Scan reserved words
        elsif s = ss.scan(/(true|false|null)/)
          buf += s

        # Scan numbers
        elsif s = ss.scan(/-?\d+([.]\d+)?([eE][-+]?[0-9]+)?/)
          buf += s

        # Remove C++ style comments
        elsif s = ss.scan(%r{//})
          ss.scan_until(/(\r?\n|$)/)

        # Remove C style comments
        elsif s = ss.scan(%r{/[*]})
          ss.scan_until(%r{[*]/}) || raise(SyntaxError.new "Unterminated /*...*/ comment - #{ss.rest}")

        # Anything else is invalid JSON
        else
          raise SyntaxError.new "Unable to pre-scan string: #{ss.rest}"
        end
      end

      buf
    end

    def minify_parse(buf)
      JSON.parse(minify(buf))
    end
  end
end

module JSON
  extend JSON::Minify
end
