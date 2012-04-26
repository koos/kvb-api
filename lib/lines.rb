require "open-uri"
require "nokogiri"

Lines = Struct.new(:line_id) do

  NBSP = Nokogiri::HTML("&nbsp;").text

  def call
    table.children.each_with_object([]) do |col, memo|
      link = col.child.child
      next unless link["href"]

      station_id   = link["href"].split("/").last.to_i
      station_name = link.content

      memo << { station_id: station_id, station_name: station_name }
    end
  end

private

  def table
    url = "http://www.kvb-koeln.de/german/hst/showline/0/#{line_id}/"
    puts "opening: #{url}"
    response = open(url)
    Nokogiri::HTML.parse(response).css("#content table")
  end

  def clean_content(node)
    node.content.gsub(NBSP, "")
  end

end
