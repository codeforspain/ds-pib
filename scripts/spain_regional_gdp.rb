require 'rubygems'
require 'bundler'
require 'open-uri'
require 'csv'
require 'json'

Bundler.require

URL = "http://www.ine.es/jaxi/files/_px/es/px/t35/p010/base2010/l0/01001.px?nocab=1"

DICTIONARY = {
  "Illes Balears" => 'Baleares',
  "Castilla - La Mancha" => "Castilla-La Mancha",
  "Comunitat Valenciana" => "Comunidad Valenciana"
}

def download(url)
  file = Tempfile.new('px')

  open(file.path, 'wb') do |file|
    file << open(url).read.encode!('utf-8', 'iso-8859-15')
  end

  file.path
end

def dump_data_to_json(data)
  file_path = File.expand_path('../data/spain_regional_gdp.json', File.dirname(__FILE__))
  puts " - Writting file #{file_path}"

  File.open(file_path, "wb") do |fd|
    fd.write(JSON.dump(data))
  end
end

puts
puts "Downloading GDP data..."

file_path = download(URL)

dataset = PCAxis::Dataset.new file_path

data = {}
dataset.dimension('Comunidades y ciudades autónomas').each do |raw_autonomous_region|
  if raw_autonomous_region.include?(',')
    p,q = raw_autonomous_region.split(',')
    name = [q.strip,p.strip].join(' ')
  else
    name = raw_autonomous_region
  end
  if name == "TOTAL NACIONAL"
    normalized_region = "whole country"
  else
    name = DICTIONARY[name] if DICTIONARY.has_key?(name)
    autonomous_region = INE::Places::AutonomousRegion.find_by_name(name)
    debugger if autonomous_region.nil?
    normalized_region = autonomous_region.id
  end
  data[normalized_region] = {}
  dataset.dimension("Ramas de actividad").each do |branch|
    dataset.dimension("Magnitud").each do |measure|
      dataset.dimension("periodo").each do |raw_year|
        value = dataset.data('Comunidades y ciudades autónomas' => raw_autonomous_region, 'Ramas de actividad' => branch, 'Magnitud' => measure, 'periodo' => raw_year)
        if !data[normalized_region].has_key?(branch)
          data[normalized_region][branch] = {}
        end
        if !data[normalized_region][branch].has_key?(measure)
          data[normalized_region][branch][measure] = {}
        end
        data[normalized_region][branch][measure][raw_year] = value.to_f
      end
    end
  end
end

dump_data_to_json data

puts " - Done!"
puts
