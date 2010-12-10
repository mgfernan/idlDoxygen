#!/usr/bin/ruby
# This script takes as input an idl file containing multiple functions
# or procedures and generates an equal number of files, one file
# per each function or method
# Usage is split_idl_file.rb pro_file_to_split

require 'ftools'

if( ARGV.size == 0 ) then
    print "Usage: split_idl_file.rb pro_file_to_split.pro\n"
    exit
end

pro_filename = ARGV[0]

pro_file = File.open( pro_filename )

function_string = String.new
function_name   = String.new

pro_file.each do |line|

    # Check if current line holds a function or procedure
    if( line.match( /^FUNCTION/i ) != nil ||
        line.match( /^PRO/i      ) != nil ||
        pro_file.eof? ) then

        # If function_string is not empty, we have to dump the previous
        # function content into the corresponding file
        if( function_string.size > 0 ) then

            if function_name.size > 0 then 
                print "Method >#{function_name}< being output at file\n"

                # Dump function into a file
                output_file = File.open(function_name+".pro","w")
                output_file << function_string
                output_file.close
            end
            
            # Reset function_string
            function_string = String.new
        end

        # Determine function name
        line_values   = line.split(/[ ,\,]/).flatten
        function_name = line_values[1]

    end

    # Append function
    function_string << line 
    
end



