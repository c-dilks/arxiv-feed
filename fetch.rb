#!/usr/bin/env ruby

require 'arx'
require 'colorize'

Ncols = `tput cols`.to_i
def sep() puts '='*Ncols end
def wrap(text)
  text.gsub(/(.{1,#{Ncols-5}})( +|$\n?)|(.{1,#{Ncols-5}})/, "\\1\\3\n")
end

keywords = [
  'spin',
  'asymmetry',
  'fragmentation',
]

papers = Arx(sort_by: :submitted_at) do |query|
  query.category('hep-ex')
  query.title(*keywords, connective: :or)
end

papers.each do |paper|
  sep
  puts "#{wrap(paper.title).chomp}".light_red
  sep
  puts "#{paper.url}".light_green
  puts wrap paper.abstract
  puts ''
end
