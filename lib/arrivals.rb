require "open-uri"
require "nokogiri"

Arrivals = Struct.new(:station_id) do

  NBSP = Nokogiri::HTML("&nbsp;").text

  def call
    table.children.inject([]) do |memo, col|
      line        = clean_content(col.children[0])
      destination = clean_content(col.children[1])
      arrival     = clean_content(col.children[2]).to_i

      memo << { line: line, destination: destination, arrival: arrival }
    end
  end

private

  def table
    response = open("http://www.kvb-koeln.de/qr/#{station_id}")
    Nokogiri::HTML.parse(response).css(".qr_table")
  end

  def clean_content(node)
    node.content.gsub(NBSP, "")
  end

end
