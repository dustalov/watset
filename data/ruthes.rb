#!/usr/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'set'

RUTHES = 'ruthes-v2'

concepts = {}

File.open(File.join(RUTHES, 'concepts.xml')) do |f|
  doc = Nokogiri::XML(f)

  doc.xpath('/concepts/concept').each do |concept|
    id = concept[:id].to_i
    concepts[id] = concept.xpath('./name').text
  end
end

entries = {}

File.open(File.join(RUTHES, 'text_entry.xml')) do |f|
  doc = Nokogiri::XML(f)

  doc.xpath('/entries/entry').each do |entry|
    id    = entry[:id].to_i
    name  = entry.children.find { |c| c.name == 'name' }.text
    entries[id] = name
  end
end

synonyms = Hash.new { |h, k| h[k] = Set.new }

File.open(File.join(RUTHES, 'synonyms.xml')) do |f|
  doc = Nokogiri::XML(f)

  doc.xpath('/synonyms/entry_rel').each do |relation|
    concept_id = relation[:concept_id].to_i
    entry_id   = relation[:entry_id].to_i
    synonyms[concept_id].add(entry_id)
  end
end

relations = Set.new

File.open(File.join(RUTHES, 'relations.xml')) do |f|
  doc = Nokogiri::XML(f)

  doc.xpath('/relations/rel').each do |relation|
    concept1, concept2 = relation[:from], relation[:to]

    case relation[:name]
    when 'ВЫШЕ' then relations << [concept1, concept2, :is_a]
    when 'НИЖЕ' then relations << [concept2, concept1, :is_a]
    end
  end
end

File.open('ruthes-synsets.tsv', 'w') do |synsets|
  concepts.each do |id, concept|
    synset = Set.new([concept])
    synonyms[id].each { |synonym_id| synset.add(entries[synonym_id]) }
    synsets.puts "%d\t%d\t%s" % [id, synset.length, synset.map { |w| w.gsub(/, /, ' ') }.join(', ')]
  end
end

File.open('ruthes-isas.txt', 'w') do |isas|
  relations.each do |concept1, concept2, type|
    next unless type == :is_a
    isas.puts "%s\t%s" % [concept1, concept2]
  end
end
