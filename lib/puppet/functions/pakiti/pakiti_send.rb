# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
#
# pakiti_send.rb
#

require 'net/http'
require 'net/https'

# ---- original file header ----
#
# @summary
#   ...
#
#
Puppet::Functions.create_function(:'pakiti::pakiti_send') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    

    servers, path, params, packages, debug = args

    post_packages = ''
    packages.each do |p|
      pkg = [ p['name'] ]
      pkg << (p.has_key?('version') ? p['version'] : '')
      pkg << (p.has_key?('release') ? p['release'] : '')
      pkg << (p.has_key?('arch')    ? p['arch']    : '')
      post_packages += pkg.collect{ |i| "'#{i}'" }.join(' ') + "\n"
    end

    params['pkgs'] = post_packages

    # Ruby 1.x sucks
    uri = URI.parse("https://#{servers[0]}#{path}")

    if debug
      Puppet.warning("pakiti_send(): Sending POST on #{uri.to_s} "+
                     "with parameters "+PSON.generate(params))
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true  
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(params)

    begin
      response = http.start {|h| h.request(request) }

      if debug
        Puppet.warning("pakiti_send(): Received server response "+
                       "code #{response.code} (body: '#{response.body}')")
      end

      case response
        when Net::HTTPSuccess
          return ''
        else
          return response.body
      end
    rescue Exception => e
      return e.message
    end
  
  end
end
