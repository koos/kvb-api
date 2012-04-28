require "open-uri"
require "nokogiri"

Arrivals = Struct.new(:station_id) do

  # These stations don't seem to have data on kvb.de
  SKIP_LIST = [683, 684, 685, 686, 688, 693, 694, 680, 743, 740, 741, 742, 134, 108, 107, 689, 696, 697, 681, 628, 739, 737, 736, 735, 734, 738, 731, 733, 732, 730]

  NBSP = Nokogiri::HTML("&nbsp;").text

  def import
    if SKIP_LIST.include? station_id
      @arrivals = []
    else
      @arrivals = table.children.inject([]) do |memo, col|
        line        = clean_content(col.children[0])
        destination = clean_content(col.children[1])
        arrival     = clean_content(col.children[2]).to_i

        memo << { line: line, destination: destination, arrival: arrival }
      end
    end
    self
  end

  def all
    @arrivals
  end

  def trains
    @arrivals.select {|arrival| arrival[:line].to_i < 100}
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
