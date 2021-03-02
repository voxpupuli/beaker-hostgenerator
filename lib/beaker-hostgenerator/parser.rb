require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/exceptions'
require 'cgi'

module BeakerHostGenerator
  # Functions for parsing the raw user input host layout string and turning
  # them into proper data structures suitable for processing by the Generator.
  #
  # The functions mainly perform data type conversions, like splitting the
  # single input string into a list of strings, each of which will be processed
  # further by other functions in this module.
  #
  # For example, given the raw user input string that defines the host layout,
  # you would first prepare it for tokenization via `prepare`, then split it
  # into tokens via `tokenize_layout`, and then for each token you would call
  # `is_ostype_token?` and/or `parse_node_info_token`.
  module Parser

    # Parses a single node definition into the following components:
    #
    #   * bits             Uppercase-only alphanumeric
    #                      Examples: 32, 64, POWER, S390X
    #
    #   * arbitrary_roles  Lowercase-only alphabetical & underscores
    #                      Examples: myrole, role_a
    #
    #   * roles            Lowercase-only, any combination of: u, a, c, l, d, f, m
    #                      Examples: m, mdca
    #
    #   * host_settings    Any character (see `settings_string_to_map` for details)
    #                      Examples: {hostname=foo-bar, ip.address=123.4.5.6, foo=[bar,baz]}
    #
    # This regex is the main workhorse for parsing input to beaker-hostgenerator.
    # There is a bit of pre and post parsing that happens before and after this
    # regex though.
    # Before we use this regex, we split the input containing multiple node
    # definitions into individual node definitions to be parsed by this regex
    # (see `tokenize_layout`).
    # After we use this regex, we turn the host_settings key-value string into
    # a proper Hash map (see `settings_string_to_map`).
    #
    # See Ruby Regexp class for information on the capture groups used below.
    # http://ruby-doc.org/core-2.2.0/Regexp.html#class-Regexp-label-Character+Classes
    #
    # Examples node specs and their resulting roles
    #
    #  64compile_master,zuul,meow.a
    #   * compile_master
    #   * zuul
    #   * meow
    #   * agent
    #
    #  32herp.cdma
    #   * herp
    #   * dashboard
    #   * database
    #   * master
    #   * agent
    #
    #  64dashboard,master,agent,database.
    #   * dashboard
    #   * master
    #   * agent
    #   * database
    #
    NODE_REGEX=/\A(?<bits>[A-Z0-9]+|\d+)((?<arbitrary_roles>([[:lower:]_]*|\,)*)\.)?(?<roles>[uacldfm]*)(?<host_settings>\{[[:print:]]*\})?\Z/

    module_function

    # Prepares the host input string for tokenization, such as URL-decoding.
    #
    # @param spec [String] Raw user input; well-formatted string specification
    #                      of the hosts to generate.
    #                      For example `"aix53-POWERfa%7Bhypervisor=aix%7D"`.
    # @returns [String] Input string with transformations necessary for
    #                   tokenization.
    def prepare(spec)
      CGI.unescape(spec)
    end

    # Breaks apart the host input string into chunks suitable for processing
    # by the generator. Returns an array of substrings of the input spec string.
    #
    # The input string is expected to be properly formatted using the dash `-`
    # character as a delimiter. Dashes may also be used within braces `{...}`,
    # which are used to define arbitrary key-values on a node.
    #
    # @param spec [String] Well-formatted string specification of the hosts to
    #                      generate. For example `"centos6-64m-debian8-32a"`.
    # @returns [Array<String>] Input string split into substrings suitable for
    #                          processing by the generator. For example
    #                          `["centos6", "64m", "debian8", "32a"]`.
    def tokenize_layout(layout_spec)
      # Here we allow dashes in certain parts of the spec string
      # i.e. "centos6-64m{hostname=foo-bar}-debian8-32"
      # by first replacing all occurrences of - with | that exist within
      # the braces {...}.
      #
      # So we'd end up with:
      #   "centos6-64m{hostname=foo|bar}-debian8-32"
      #
      # Which we can then simply split on - into:
      #   ["centos6", "64m{hostname=foo|bar}", "debian8", "32"]
      #
      # And then finally turn the | back into - now that we've
      # properly decomposed the spec string:
      #   ["centos6", "64m{hostname=foo-bar}", "debian8", "32"]
      #
      # NOTE we've specifically chosen to use the pipe character |
      # due to its unlikely occurrence in the user input string.
      spec = String.new(layout_spec) # Copy so we can replace characters inline
      within_braces = false
      spec.chars.each_with_index do |char, index|
        case char
        when '{'
          within_braces = true
        when '}'
          within_braces = false
        when '-'
          spec[index] = '|' if within_braces
        end
      end
      tokens = spec.split('-')
      tokens.map { |t| t.gsub('|', '-') }
    end

    # Tests if a string token represents an OS platform (i.e. "centos6" or
    # "debian8") and not another part of the host specification like the
    # architecture bit (i.e. "32" or "64").
    #
    # This is used when parsing the host generator input string to determine
    # if we're introducing a host for a new platform or if we're adding another
    # host for a current platform.
    #
    # @param [String] token A piece of the host generator input that might refer
    #                 to an OS platform. For example `"centos6"` or `"debian8"`.
    #
    # @param [Integer] bhg_version The version of OS info to use when testing
    #                  for whether the token represent an OS platform.
    def is_ostype_token?(token, bhg_version)
      BeakerHostGenerator::Data.get_platforms(bhg_version).each do |platform|
        ostype = platform.split('-')[0]
        if ostype == token
          return true
        end
      end
      return false
    end

    # Converts a string token that represents a node (and not an OS type) into
    # a proper hash map with keys representing the various regex capture groups
    # in `NODE_REGEX` and values being the captured text.
    #
    # Throws an exception if the token is not in the expected formatted, as
    # determined by `NODE_REGEX.match`.
    #
    # It is expected that the `Generator` will have initimate knowledge about
    # the keys and values in the returned map, as it may be adjusted and given
    # to the hypervisors or other abstractions for processing.
    #
    # @param token [String] The portion of the user input layout specifiction
    #                       that describes the node (and not the OS platform).
    #                       For example `"64myrole.mdca"`.
    #
    # @returns [Hash{String=>Object}] A map containing the regex capture groups
    #                                 suitable for processing by the Generator
    #                                 and hypervisors.
    def parse_node_info_token(token)
      node_info = NODE_REGEX.match(token)

      if node_info
        node_info = Hash[ node_info.names.zip( node_info.captures ) ]
      else
        raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError.new,
              "Invalid node_info token: #{token}"
      end

      if node_info['arbitrary_roles']
        node_info['arbitrary_roles'] =
          node_info['arbitrary_roles'].split(',') || ''
      else
        # Default to empty list to avoid having to check for nil elsewhere
        node_info['arbitrary_roles'] = []
      end

      if node_info['host_settings']
        node_info['host_settings'] =
          settings_string_to_map(node_info['host_settings'])
      else
        node_info['host_settings'] = {}
      end

      return node_info
    end

    # Transforms the arbitrary host settings map from a string representation
    # to a proper hash map data structure for merging into the host
    # configuration. Supports arbitrary nested hashes and arrays.
    #
    # The string is expected to be of the form "{key1=value1,key2=[v2,v3],...}".
    # Nesting looks like "{key1={nested_key=nested_value},list=[[list1, list2]]}".
    # Whitespace is expected to be properly quoted as it will not be treated
    # any different than non-whitespace characters.
    #
    # Throws an exception of the string is malformed in any way.
    #
    # @param host_settings [String] Non-nil user input string that defines host
    #                               specific settings.
    #
    # @returns [Hash{String=>String|Array|Hash}] The host_settings string as a map.
    def settings_string_to_map(host_settings)

      stringscan = StringScanner.new(host_settings)
      object = nil
      object_depth = []
      current_depth = 0

      # This loop scans until the next delimiter character is found. When
      # the next delimiter is recognized, there is enough context in the
      # substring to determine a course of action to modify the primary
      # object. The `object_depth` object tracks which current object is
      # being modified, and pops it off the end of the array when that
      # data structure is completed.
      #
      # This algorithm would also support a base array, but since there
      # is no need for that functionality, we just assume the string is
      # always a representation of a hash.
      loop do
        blob = stringscan.scan_until(/\[|{|}|\]|,/)

        break if blob.nil?

        if stringscan.pos() == 1
          object = {}
          object_depth.push(object)
          next
        end

        current_type = object_depth[current_depth].class
        current_object = object_depth[current_depth]

        if blob == '['
          current_object.push([])
          object_depth.push(current_object.last)
          current_depth = current_depth.next
          next
        end

        if blob.start_with?('{')
          current_object.push({})
          object_depth.push(current_object.last)
          current_depth = current_depth.next
          next
        end



        if blob == ']' or blob == '}'
          object_depth.pop
          current_depth = current_depth.pred
          next
        end

        # When there is assignment happening, we need to create a new
        # corresponding data structure, add it to the object depth, and
        # then change the current depth
        if blob[-2] == '='
          raise Beaker::HostGenerator::Exceptions::InvalidNodeSpecError unless blob.end_with?('{','[')
          if blob[-1] == '{'
            current_object[blob[0..-3]] = {}
          else
            current_object[blob[0..-3]] = []
          end
          object_depth.push(current_object[blob[0..-3]])
          current_depth = current_depth.next
          next
        end

        if blob[-1] == '}'
          raise Beaker::HostGenerator::Exceptions::InvalidNodeSpecError if blob.count('=') != 1
          key_pair = blob[0..-2].split('=')
          raise Beaker::HostGenerator::Exceptions::InvalidNodeSpecError if key_pair.size != 2
          key_pair.each do |element|
            raise Beaker::HostGenerator::Exceptions::InvalidNodeSpecError if element.empty?
          end
          current_object[key_pair[0]] = key_pair[1]
          object_depth.pop
          current_depth = current_depth.pred
          next
        end

        if blob == ','
          next
        end

        if blob[-1] == ','
          if current_type == Hash
            key_pair = blob[0..-2].split('=')
            raise Beaker::HostGenerator::Exceptions::InvalidNodeSpecError if key_pair.size != 2
            key_pair.each do |element|
              raise Beaker::HostGenerator::Exceptions::InvalidNodeSpecError if element.empty?
            end
            current_object[key_pair[0]] = key_pair[1]
            next
          elsif current_type == Array
            current_object.push(blob[0..-2])
            next
          end
        end

        if blob[-1] == ']'
          current_object.push(blob[0..-2])
          object_depth.pop
          current_depth = current_depth.pred
          next
        end
      end

      object
    rescue Exception => e
      raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
        "Malformed host settings: #{host_settings}"
    end

  end
end
