#!/usr/bin/env ruby

require 'arx'
require 'colorize'

# search terms
keywords = [
  'spin',
  'asymmetry',
  'fragmentation',
  'dihadron',
  'di hadron', # (actually finds 'di-hadron')
]

# query arXiv
papers = Arx(sort_by: :submitted_at) do |query|
  query.category('hep-ex')
  query.title(*keywords, connective: :or)
end

# print
ResultFileN = "arxiv.tmp"
ResultFile = File.open(ResultFileN,"w")
Ncols = `tput cols`.to_i
def sep(stream=ResultFile) stream.puts '='*Ncols end
def printField(text, color=:default, stream=ResultFile)
  wrappedText = text.gsub(/(.{1,#{Ncols-5}})( +|$\n?)|(.{1,#{Ncols-5}})/, "\\1\\3\n")
  coloredText = wrappedText.split("\n").map{|tok|tok.colorize(color)}.join("\n")
  stream.puts "#{coloredText.chomp}"
end
papers.each do |paper|
  sep
  printField(paper.title,:light_red)
  sep
  printField(paper.url,:light_green)
  printField(paper.updated_at.strftime("%d %b %Y"),:yellow)
  authors = paper.authors.map(&:name)
  authors = authors[0..4].append("et al.") if authors.length>5
  printField(authors.join(', '),:magenta)
  printField(paper.abstract)
  printField('')
end
ResultFile.close
system "less -R #{ResultFileN}"
File.delete(ResultFileN)
