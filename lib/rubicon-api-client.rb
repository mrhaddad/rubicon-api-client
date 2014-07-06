require 'uri'
require 'net/http'
require 'net/http/digest_auth'
module RubiconApiClient
  class RubiconClient
    @@host = 'https://api.rubiconproject.com'


    def whens
      ['today', 'yesterday', 'this week', 'last week', 'this month', 'last month', 'this year', 'last 7', 'last 30', 'all']
    end

    def response_formats
        { :xml => 'application/xml', :json => 'application/json', :csv => 'text/csv' }
    end


    def initialize(id, key, secret, format=:xml)
      @id = id
      @key = key
      @secret = secret
      @response_format = response_formats[format]
    end

    def execute(path)
      uri = URI.parse @@host
      net = Net::HTTP.new uri.host
      req = Net::HTTP::Get.new path
      req.basic_auth(@key, @secret)
      req['Accept'] = @response_format
      res = net.request req
      res.read_body
    end

    def compose_arguments(hash)
      args = []
      hash.each_key do |key|
        hash[key] = [hash[key]] if !hash[key].is_a?(Array)
        args << "#{key}=#{hash[key].join(',')}" unless hash[key][0] == '' || hash[key][0].nil?
      end
      URI.escape '?'+args.join('&')
    end

    def parse_date(date_range_splat)
      args = {}
      if whens.include? date_range_splat[0].to_s
        args['when'] = date_range_splat[0].to_s
      elsif date_range_splat.length == 2
        args['start'] = Date.parse(date_range_splat[0].to_s).to_s
        args['end'] = Date.parse(date_range_splat[1].to_s).to_s
      end
      args
    end
  end

  class Seller < RubiconClient
    def zone_performance_report(site_ids='',*date_range)

      args = parse_date date_range

      args['site_id'] = site_ids

      path = "/seller/api/ips/v1/reports/zone/performance/#{@id}/#{compose_arguments args}"
      execute(path)
    end

    def ad_hoc_performance_report(columns, currency=nil, *date_range)
      args = parse_date date_range
      args['currency'] = currency
      args['columns'] = columns
      args['source'] = 'standard'

      path = "/sellers/api/reports/v1/#{@id}/#{compose_arguments args}"
      execute(path)
    end

    def execute(path)
      super path
    end
  end
end
