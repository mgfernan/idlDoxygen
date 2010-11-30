#!/usr/bin/ruby

require 'ftools'

IDL_FILE_EXTENSION = "pro"
DOXYGEN_COMMENT    = ";/"


class Function

    attr_accessor :name, :compulsoryParameters, :optionalParameters
    attr_accessor :returnType

    def initialize( string, functionIdentifier )

        @returnType = (functionIdentifier == "PRO"? "void" : "")
        @compulsoryParameters = Array.new
        @optionalParameters   = Array.new

        # Remove function identifier
        functionRegexp = Regexp.new("#{functionIdentifier} ", true)
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
        [@compulsoryParameters,@optionalParameters].flatten.each do |parameter|
            prototype << "#{parameter}, "
        end
        prototype << ")\n"

        #Remove empty parameter slots
        prototype.sub!( ", )", " )" )

        print prototype
    end

end


# Search for files with IDL extension

# Searches all the IDL files 
proFiles = File.join("**", "*.#{IDL_FILE_EXTENSION}")

# Processes all the IDL files (converts to pseudo-C)
Dir.glob( proFiles ) do |proFile| 

    File.open( proFile ).each do |fileLine|

        # Comments should follow this structure
        # ;/ @brief Including brief description
        # ;/ Detailed description or in-function comment

        # Remove leading and trailing whitespaces
        strippedFileLine = fileLine.strip

        # Creation of Regexp strings for the Brief and detailed
        # markers
        doxygenCommentRegexp = Regexp.new("^#{DOXYGEN_COMMENT}")

        if( strippedFileLine.match( /^PRO/i )      != nil ) then 
            function = Function.new( fileLine, "PRO" ).printPrototype
            print "{\n"
        end

        if( strippedFileLine.match( /^FUNCTION/i ) != nil ) then
            function = Function.new( fileLine, "FUNCTION" ).printPrototype
            print "{\n"
        end

        if( strippedFileLine.match( /^END/i )      != nil ) then
            print "}\n"
        end
        if( strippedFileLine.match( doxygenCommentRegexp )  != nil ) then
            print fileLine.gsub(/;/,"//")
        end

    end
end

