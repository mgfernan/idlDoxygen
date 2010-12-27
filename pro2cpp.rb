#!/usr/bin/ruby

require 'ftools'

IDL_FILE_EXTENSION = "pro"
DOXYGEN_COMMENT    = ";/"


class Function

    attr_accessor :name, :functionIdentifier
    attr_accessor :compulsoryParameters, :optionalParameters
    attr_accessor :returnType

    def initialize( string, functionIdentifier )

        @functionIdentifier = functionIdentifier
        @returnType = (@functionIdentifier == "PRO"? "void" : "")
        @compulsoryParameters = Array.new
        @optionalParameters   = Array.new

        # Remove function identifier
        functionRegexp = Regexp.new("#{@functionIdentifier} ", true)
        string.sub!( functionRegexp,'')

        # Strip the different parameters and options using comma
        # as the separator
        string.split(',').each_with_index do |functionItem,iFunctionItem|
            functionItem.strip!
            if( iFunctionItem == 0 ) then
                @name = functionItem
                next
            else
                #Check if it contains an equal (i.e. optional keyword)
                if( functionItem.match(/=/) == nil ) then
                    # We are in front of a compulsory parameter
                    @compulsoryParameters << functionItem
                else
                    # We are in front of an optional parameter
                    @optionalParameters << functionItem.split(/=/).at(0)
                end
            end

        end

    end

    def printPrototype

        prototype = "#{@returnType} #{@name}( "
        [@compulsoryParameters].flatten.each do |parameter|
            prototype << "argument #{parameter}, "
        end
        [@optionalParameters].flatten.each do |parameter|
            prototype << "optional #{parameter}, "
        end
        prototype << ")\n"

        #Remove empty parameter slots
        prototype.sub!( ", )", " )" )

        print prototype
    end

end

def is_multiline( string )

    clean_string = string.strip
    clean_string_length = clean_string.size
    last_character = clean_string[ clean_string_length-1 ]
    return ( last_character.chr=='$' )

end

# Input check
exit if( ARGV.size == 0 ) 

# Define input file
proFileName = ARGV[0]

proFile = File.open( proFileName )

proFile.each do |fileLine|

    # Comments should follow this structure
    # ;/ @brief Including brief description
    # ;/ Detailed description or in-function comment

    # Remove leading and trailing whitespaces
    strippedFileLine = fileLine.strip

    # Creation of Regexp strings for the Brief and detailed
    # markers
    doxygenCommentRegexp = Regexp.new("^#{DOXYGEN_COMMENT}")

    if( strippedFileLine.match( /^FUNCTION/i ) != nil ||
        strippedFileLine.match( /^PRO/i      ) != nil ) then

        function_type = ( strippedFileLine.match( /^PRO/i )!=nil ? "PRO" : "FUNCTION" )

        string_with_function = strippedFileLine 

        while is_multiline( string_with_function ) do

            # Remove last character (that contains the $ character)
            string_with_function = string_with_function[0...string_with_function.size-1]
            
            # Read next line and remove the leading and trailing spaces
            next_line = proFile.readline.strip

            # Append line to the function holding the string
            string_with_function << next_line

        end

        function = Function.new( string_with_function, function_type ).printPrototype
        print "{\n"
        print "    /// This method is a #{function_type} (i.e. returns a value)\n\n"
    end

    if( strippedFileLine.match( /^END/i )      != nil ) then
        print "}\n"
    end
    if( strippedFileLine.match( doxygenCommentRegexp )  != nil ) then
        print fileLine.gsub(/;/,"//")
    end

end

