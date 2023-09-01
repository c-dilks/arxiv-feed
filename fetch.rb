#!/usr/bin/env ruby

require 'arx'
require 'colorize'

# settings
MAX_RESULTS = 30 # number of results

# arguments
if ARGV.length<1
  $stderr.puts """
  USAGE: #{$0} [MODE]...

    modes:
    - 1: spin, dihadrons, fragmentation
    - 2: instrumentation and detectors

    specify multiple modes to OR them together
  """
  exit 2
end
modes = ARGV.map(&:to_i)

# set search keywords and categories
keywords = []
categories = []
modes.each do |mode|
  case mode
  when 1
    categories.append *[
      'hep-ex',
      'hep-th',
      'hep-ph',
      'hep-lat',
      'nucl-ex',
    ]
    keywords.append *[
      'spin',
      'asymmetry',
      'fragmentation',
      'dihadron',
      'di hadron', # (actually finds 'di-hadron')
    ]
  when 2
    categories.append 'physics.ins-det'
  else
    $stderr.puts "\n\nERROR: unknown mode #{mode}\n\n"
  end
end
puts "categories = #{categories}"
puts "keywords = #{keywords}"

# query arXiv
puts "querying arXiv..."
papers = Arx(sort_by: :submitted_at, max_results: MAX_RESULTS-1) do |query|
  query.category(*categories, connective: :or) if categories.length>0
  query.title(*keywords, connective: :or) if keywords.length>0
end

# print
ResultFileN = "arxiv.tmp"
ResultFile = File.open(ResultFileN,"w")
Ncols = `tput cols`.to_i
def sep(stream=ResultFile) stream.puts '='*Ncols end
def printField(text, color=:default, style=:default, stream=ResultFile)
  wrappedText = text.gsub(/(.{1,#{Ncols-5}})( +|$\n?)|(.{1,#{Ncols-5}})/, "\\1\\3\n")
  coloredText = wrappedText.split("\n").map{|tok|tok.colorize(:color=>color,:mode=>style)}.join("\n")
  stream.puts "#{coloredText.chomp}"
end
papers.each_with_index do |paper, idx|
  sep
  printField("#{idx}.   #{paper.title}",:light_green,:bold)
  sep
  printField(paper.url,:light_red)
  printField(paper.primary_category.name,:light_white)
  printField(paper.updated_at.strftime("%d %b %Y"),:light_yellow)
  authors = paper.authors.map(&:name)
  authors = authors[0..4].append("et al.") if authors.length>5
  printField(authors.join(', '),:light_magenta)
  printField(paper.abstract,:light_cyan)
  printField('')
end
ResultFile.close
system "less -R #{ResultFileN}"
File.delete(ResultFileN)
