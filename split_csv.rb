#!/usr/bin/ruby

=begin

This is a simple script for splitting a csv file into multiple smaller files

=end

require "rubygems"
require "csv"
require 'ostruct'
require 'optparse'

$output_total = 0
$output_index = 0
$output_row_count = 0
$max_records_per_file = 500
$max_records_total = 0

def self.parse(args)
	options = OpenStruct.new

	options.num_rows = $max_records_per_file

	opt_parser = OptionParser.new do |opts|
		opts.banner = "Usage: split_csv.rb [options]"

		opts.on("-rROWS", "--num-rows", "Number of rows in output file") do |o|
			options.num_rows = o.to_i
		end

		opts.on("-iINPUT", "--input INPUT", "Input File") do |o|
			options.input = o
		end

		opts.on("-oOUTPUT", "--output OUTPUT", "Output File(s)") do |o|
			options.output = o
		end

		# No argument, shows at tail.  This will print an options summary.
		opts.on_tail("-h", "--help", "Show this message") do
			puts opts
			exit
		end

	end

	opt_parser.parse!(args)
	options
end

def output_csv()
	CSV.open($options.output.sub(".csv", "_#{$output_index}.csv"), "w") do |output_csv|

		$output_content.each { |row|
			output_csv << row
		}

		$output_index += 1
		$output_row_count = 0
		$output_content = []
	end
end


$options = parse(ARGV)

if $options.input == nil || $options.output == nil
	puts "You must specify both an input and output"
	exit
end

puts "input:#{$options.input} num rows:#{$options.num_rows}"

$output_content = []
csv = CSV::parse(File.open($options.input, "r:ISO-8859-1") { |f| f.read })
csv.each do |csvrow|

	$output_content << csvrow

	$output_row_count += 1
	$output_total += 1

	if $output_row_count >= $options.num_rows
		output_csv
	end

	if $max_records_total > 0 && $output_total >= $max_records_total
		break
	end
end

# sweep output
if $output_row_count > 0
	output_csv
end

