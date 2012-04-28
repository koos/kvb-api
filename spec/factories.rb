FactoryGirl.define do
  factory :station do
    sequence(:name) { |n| "Station #{n}" }
  end

  factory :station_alias do
    sequence(:name) { |n| "Alias #{n}" }
  end

  factory :station_with_aliases, parent: :station do
    after_create do |station|
      FactoryGirl.create(:station_alias, name: "#{station.name} alias 1", station_id: station.id)
      FactoryGirl.create(:station_alias, name: "#{station.name} alias 2", station_id: station.id)
    end
  end

  factory :line do
    sequence(:number) { |n| n }
    kind 'bahn'
  end

  factory :station_connection do
    association :station_a, factory: :station
    association :station_b, factory: :station
  end

  factory :line_connection do
    association :line, factory: :line
  end
end
